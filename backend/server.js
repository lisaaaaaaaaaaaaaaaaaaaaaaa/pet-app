const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: process.env.FIREBASE_PROJECT_ID,
});

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Auth middleware
const authenticateUser = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    if (!token) throw new Error('No token provided');
    
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Unauthorized' });
  }
};

// Create subscription endpoint
app.post('/create-subscription', authenticateUser, async (req, res) => {
  try {
    const { userId, email, plan } = req.body;

    // Create or get customer
    let customer = await stripe.customers.list({
      email: email,
      limit: 1
    });

    if (customer.data.length === 0) {
      customer = await stripe.customers.create({
        email: email,
        metadata: {
          firebaseUID: userId
        }
      });
    } else {
      customer = customer.data[0];
    }

    // Create subscription
    const subscription = await stripe.subscriptions.create({
      customer: customer.id,
      items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: 'Golden Years Premium',
            description: 'Full access to all premium features',
          },
          unit_amount: 1000, // $10.00
          recurring: {
            interval: 'month',
          },
        },
      }],
      payment_behavior: 'default_incomplete',
      payment_settings: { save_default_payment_method: 'on_subscription' },
      expand: ['latest_invoice.payment_intent'],
    });

    // Create ephemeral key
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: '2023-10-16' }
    );

    res.json({
      subscriptionId: subscription.id,
      clientSecret: subscription.latest_invoice.payment_intent.client_secret,
      customer: customer.id,
      ephemeralKey: ephemeralKey.secret,
    });
  } catch (error) {
    console.error('Subscription creation error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Cancel subscription endpoint
app.post('/cancel-subscription', authenticateUser, async (req, res) => {
  try {
    const { subscriptionId, userId } = req.body;

    // Verify user owns subscription
    const subscription = await stripe.subscriptions.retrieve(subscriptionId);
    const customer = await stripe.customers.retrieve(subscription.customer);

    if (customer.metadata.firebaseUID !== userId) {
      throw new Error('Unauthorized to cancel this subscription');
    }

    const canceledSubscription = await stripe.subscriptions.cancel(subscriptionId);
    
    res.json({ subscription: canceledSubscription });
  } catch (error) {
    console.error('Subscription cancellation error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Update payment method endpoint
app.post('/update-payment-method', authenticateUser, async (req, res) => {
  try {
    const { paymentMethodId, userId } = req.body;

    // Get customer by Firebase UID
    const customers = await stripe.customers.list({
      limit: 1,
      metadata: { firebaseUID: userId }
    });

    if (customers.data.length === 0) {
      throw new Error('Customer not found');
    }

    const customer = customers.data[0];

    // Attach payment method to customer
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customer.id,
    });

    // Set as default payment method
    await stripe.customers.update(customer.id, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Payment method update error:', error);
    res.status(400).json({ error: error.message });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server running on port ${port}`));
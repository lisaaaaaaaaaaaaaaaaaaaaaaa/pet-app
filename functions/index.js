const functions = require('firebase-functions');
const stripe = require('stripe')('sk_test_YOUR_NEW_SECRET_KEY');

exports.createSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  try {
    // Create or get customer
    const customerData = await stripe.customers.list({
      email: context.auth.token.email,
      limit: 1
    });
    
    let customer;
    if (customerData.data.length === 0) {
      customer = await stripe.customers.create({
        email: context.auth.token.email,
      });
    } else {
      customer = customerData.data[0];
    }

    // Create subscription
    const subscription = await stripe.subscriptions.create({
      customer: customer.id,
      items: [{ 
        price: 'price_1QML98P3QmxDRtPcHkVqQveE'
      }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent'],
      metadata: {
        productId: 'prod_REom1syfyqRAwx'
      }
    });

    // Create ephemeral key
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: '2023-10-16' }
    );

    return {
      paymentIntent: subscription.latest_invoice.payment_intent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
      subscription: subscription.id
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.cancelSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  try {
    const subscription = await stripe.subscriptions.cancel(data.subscriptionId);
    return { success: true, subscription };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.updatePaymentMethod = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  try {
    const paymentMethod = await stripe.paymentMethods.attach(
      data.paymentMethodId,
      { customer: data.customerId }
    );

    await stripe.customers.update(
      data.customerId,
      { invoice_settings: { default_payment_method: paymentMethod.id } }
    );

    return { success: true, paymentMethod };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const logger = require('../utils/logger');

const handleWebhook = async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.rawBody,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    logger.error(`Webhook Error: ${err.message}`);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    switch (event.type) {
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object;
        logger.info(`PaymentIntent succeeded: ${paymentIntent.id}`);
        // Handle successful payment
        break;
      case 'payment_intent.payment_failed':
        const failedPayment = event.data.object;
        logger.error(`Payment failed: ${failedPayment.id}`, {
          error: failedPayment.last_payment_error
        });
        break;
      case 'customer.subscription.created':
        const subscription = event.data.object;
        logger.info(`Subscription created: ${subscription.id}`);
        break;
      case 'customer.subscription.updated':
        const updatedSubscription = event.data.object;
        logger.info(`Subscription updated: ${updatedSubscription.id}`);
        break;
      case 'customer.subscription.deleted':
        const deletedSubscription = event.data.object;
        logger.info(`Subscription cancelled: ${deletedSubscription.id}`);
        break;
      default:
        logger.info(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (err) {
    logger.error('Error processing webhook:', err);
    res.status(500).send('Webhook processing failed');
  }
};

module.exports = handleWebhook;

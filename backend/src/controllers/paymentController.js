const { Preference, Payment } = require('mercadopago');
const mpClient = require('../config/mercadopago');
const Order = require('../models/order');

const createPreference = async (req, res) => {
  try {
    const { orderId } = req.body;

    const order = await Order.findOne({ _id: orderId, user: req.user._id });
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    const preference = new Preference(mpClient);

    const items = order.items.map((item) => ({
      id: item.product.toString(),
      title: item.name,
      quantity: item.quantity,
      unit_price: item.price,
      currency_id: 'ARS',
    }));

    const preferenceData = await preference.create({
      body: {
        items,
        external_reference: order._id.toString(),
        back_urls: {
          success: `${process.env.FRONTEND_URL}/payment/success`,
          failure: `${process.env.FRONTEND_URL}/payment/failure`,
          pending: `${process.env.FRONTEND_URL}/payment/pending`,
        },
        auto_return: 'approved',
        notification_url: `${process.env.BACKEND_URL}/api/payments/webhook`,
      },
    });

    res.json({ preferenceId: preferenceData.id, initPoint: preferenceData.init_point });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const handleWebhook = async (req, res) => {
  try {
    const { type, data } = req.body;

    if (type === 'payment') {
      const paymentClient = new Payment(mpClient);
      const paymentInfo = await paymentClient.get({ id: data.id });

      const orderId = paymentInfo.external_reference;
      const status = paymentInfo.status;

      const paymentStatusMap = {
        approved: { paymentStatus: 'approved', status: 'paid' },
        rejected: { paymentStatus: 'rejected', status: 'cancelled' },
        in_process: { paymentStatus: 'in_process', status: 'pending' },
        pending: { paymentStatus: 'pending', status: 'pending' },
      };

      const update = paymentStatusMap[status] || {};

      await Order.findByIdAndUpdate(orderId, {
        paymentId: String(data.id),
        ...update,
      });
    }

    res.sendStatus(200);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getPaymentStatus = async (req, res) => {
  try {
    const order = await Order.findOne({ _id: req.params.orderId, user: req.user._id });
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }
    res.json({ paymentStatus: order.paymentStatus, orderStatus: order.status });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { createPreference, handleWebhook, getPaymentStatus };

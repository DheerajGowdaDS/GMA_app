// routes/baby.js
const express = require('express');
const router = express.Router();
const Baby = require('../models/Baby'); // Mongoose model

router.post('/add-baby', async (req, res) => {
  const { nameOrId, age, address } = req.body; // ✅ Make sure address is included

  try {
    const newBaby = new Baby({ nameOrId, age, address }); // ✅ Save address
    await newBaby.save();

    res.status(201).json({ message: 'Baby data saved', baby: newBaby });
  } catch (error) {
    console.error('Error saving baby data:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

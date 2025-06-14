// models/Baby.js
const mongoose = require('mongoose');

const BabySchema = new mongoose.Schema({
  nameOrId: { type: String, required: true },
  age: { type: String, required: true },
  address: { type: String }, // ✅ Address field
});

module.exports = mongoose.model('Baby', BabySchema, 'baby_data'); // Uses 'baby_data' instead of 'babies'


// backend/models/Video.js
const mongoose = require('mongoose');

const videoSchema = new mongoose.Schema({
  title: { type: String, required: true },
  url: { type: String, required: true },
  status: {
    type: String,
    enum: ['pending', 'flagged', 'approved'],
    default: 'pending',
  },
  uploadedAt: { type: Date, default: Date.now },
});

const Video = mongoose.model('Video', videoSchema);

module.exports = Video;

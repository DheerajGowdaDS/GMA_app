require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const Video = require('./models/Video'); // import your model here
const app = express();
const PORT = process.env.PORT || 5000;
const multer = require('multer');
const path = require('path');

app.use((req, res, next) => {
  console.log(`Incoming request: ${req.method} ${req.url}`);
  next();
});

// Middleware
app.use(cors({
  origin: '*', // Allow all origins for development; restrict in production
  methods: ['GET', 'POST', 'PATCH', 'DELETE'],
}));
app.use(express.json()); // Parse JSON body
app.use('/uploads', express.static('uploads'));

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected successfully'))
.catch((err) => {
  console.error('MongoDB connection error:', err);
  process.exit(1);
});

// Test route
app.get('/', (req, res) => {
  res.send('Hello from Node.js backend!');
});

// Get videos by status
app.get('/api/videos/:status', async (req, res) => {
  try {
    const { status } = req.params;
    if (!['pending', 'flagged', 'approved'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status parameter' });
    }

    const videos = await Video.find({ status }).select('title url -_id').exec();
    res.json(videos);
  } catch (error) {
    console.error('Error fetching videos:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Add new video
app.post('/api/videos', async (req, res) => {
  console.log('Received body:', req.body);  // <-- add this line

  try {
    const { title, url, status } = req.body;

    if (!title || !url) {
      return res.status(400).json({ error: 'Title and URL are required' });
    }

    if (status && !['pending', 'flagged', 'approved'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status value' });
    }

    const video = new Video({ title, url, status });
    await video.save();

    res.status(201).json({ message: 'Video added successfully', video });
  } catch (error) {
    console.error('Error adding video:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update video status
app.patch('/api/videos/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['pending', 'flagged', 'approved'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status value' });
    }

    const video = await Video.findByIdAndUpdate(id, { status }, { new: true, runValidators: true });

    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    res.json({ message: 'Status updated successfully', video });
  } catch (error) {
    console.error('Error updating status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete video
app.delete('/api/videos/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const video = await Video.findByIdAndDelete(id);
    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    res.json({ message: 'Video deleted successfully' });
  } catch (error) {
    console.error('Error deleting video:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');  // Make sure this folder exists
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname)); // e.g., 1623456789.mp4
  }
});

const upload = multer({ storage: storage });

// POST endpoint to upload video file
app.post('/api/videos/upload', upload.single('video'), async (req, res) => {
  try {
    // req.file contains info about uploaded file
    // req.body contains other form fields

    const { title, status } = req.body;
    if (!title) return res.status(400).json({ error: 'Title is required' });
    if (status && !['pending', 'flagged', 'approved'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'Video file is required' });
    }

    // Save video info to MongoDB including path
    const video = new Video({
      title,
      url: `/uploads/${req.file.filename}`,  // Save relative path to serve file later
      status: status || 'pending',
    });
    await video.save();

    res.status(201).json({ message: 'Video uploaded successfully', video });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});
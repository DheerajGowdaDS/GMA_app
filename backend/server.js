const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const authRoutes = require('./routes/auth');

const app = express();

// Enable CORS and JSON body parsing
app.use(cors({ origin: '*' }));
app.use(express.json());

// ✅ MongoDB Atlas connection URI (corrected)
const mongoURI = 'mongodb+srv://hemantshet25:LUORz5jUnYRihtYr@cluster0.k49orpx.mongodb.net/hemant?retryWrites=true&w=majority&appName=Cluster0';

// Connect to MongoDB
mongoose.connect(mongoURI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('✅ MongoDB connected'))
.catch((err) => console.log('❌ MongoDB error:', err));

// API Routes
app.use('/api', authRoutes);

// Start the server on all interfaces (important for Android access)
const PORT = 3000;
app.listen(3000, '0.0.0.0', () => {
  console.log("Server running on port 3000");
});

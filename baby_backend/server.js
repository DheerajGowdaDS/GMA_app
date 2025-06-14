const express = require('express');
const connectDB = require('./db');
const babyRoutes = require('./routes/api'); // ✅ your route file

const app = express();

// Connect to MongoDB
connectDB();

// Middleware
app.use(express.json());

// Use routes
app.use('/api', babyRoutes); // ✅ This makes /api/add-baby available

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));

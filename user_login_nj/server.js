require('dotenv').config();               // 1. Load .env right away
const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const User = require('./models/user');    // adjust path/name if needed

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 5000;

// --- 1. CONNECT TO MONGODB ATLAS ---
console.log('Connecting with URI:', process.env.MONGO_URI);
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// --- 2. REGISTRATION ENDPOINT ---
app.post('/api/register', async (req, res) => {
  console.log('→ Registration payload:', req.body);

  try {
    const { name, phone, email, password } = req.body;

    // Basic validation
    if (!name || !phone || !email || !password) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    // 2.1. Check for existing user
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // 2.2. Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 2.3. Save new user
    const newUser = new User({
      name,
      phone,
      email,
      password: hashedPassword
    });
    await newUser.save();

    console.log('✓ New user created:', newUser._id);
    return res.status(201).json({ message: 'Account created successfully' });

  } catch (err) {
    console.error('Registration error details:', err);
    return res.status(500).json({ message: 'Server error during registration' });
  }
});

// --- 3. LOGIN ENDPOINT ---
app.post('/api/login', async (req, res) => {
  console.log('→ Login payload:', req.body);

  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    // 3.1. Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // 3.2. Compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // 3.3. Generate JWT
    const payload = { userId: user._id, email: user.email };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    console.log('✓ User logged in:', user._id);
    return res.status(200).json({
      message: 'Login successful',
      token,
      user: { id: user._id, name: user.name, email: user.email, phone: user.phone }
    });

  } catch (err) {
    console.error('Login error details:', err);
    return res.status(500).json({ message: 'Server error during login' });
  }
});

// --- 4. START THE SERVER ---
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

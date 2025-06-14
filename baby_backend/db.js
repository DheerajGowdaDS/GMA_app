const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect('mongodb+srv://sbharath9686:bharathsmongo@babycluster.qsdlmjq.mongodb.net/yourDatabaseName?retryWrites=true&w=majority&appName=BabyCluster&authSource=admin');
    console.log('✅ MongoDB connected');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  }
};

module.exports = connectDB;

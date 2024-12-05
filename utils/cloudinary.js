require("dotenv").config()
const { v2: cloudinary } = require("cloudinary")

// Ensure these environment variables are set correctly in your .env file
cloudinary.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.API_KEY,
  api_secret: process.env.API_SECRET,
})

module.exports = cloudinary

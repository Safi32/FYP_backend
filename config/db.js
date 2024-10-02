require("dotenv").config()
const mongoose = require("mongoose")

const dbConnect = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URL)
    console.log("Database Connected")
  } catch (err) {
    console.log("Database connection error:", err)
  }
}

module.exports = {
  dbConnect,
}

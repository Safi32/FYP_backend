const mongoose = require("mongoose");

const dealSchema = new mongoose.Schema({
  name: { type: String, required: true },
  category: { type: String, required: true },
  price: { type: Number, required: true },
  details: { type: String, required: true },
  image: { type: String }, // Path to the uploaded image
}, { timestamps: true });

module.exports = mongoose.model("Deal", dealSchema);

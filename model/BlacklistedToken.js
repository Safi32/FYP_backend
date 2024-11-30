const mongoose = require("mongoose");

const blacklistedTokenSchema = new mongoose.Schema({
  token: { type: String, required: true },
  expiresAt: { type: Date, required: true }, // Store the expiration date of the token
});

module.exports = mongoose.model("BlacklistedToken", blacklistedTokenSchema);

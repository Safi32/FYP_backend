const mongoose = require("mongoose");

const reservationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true }, // User making the reservation
  restaurantId: { type: mongoose.Schema.Types.ObjectId, ref: "Restaurant", required: true }, // Restaurant receiving the request
  username: { type: String, required: true }, // Username of the user
  date: { type: Date, required: true }, // Reservation date and time
  persons: { type: Number, required: true }, // Number of people
  tableNumber: { type: String, required: true }, // Selected table
  status: { type: String, enum: ["Pending", "Accepted", "Rejected"], default: "Pending" }, // Reservation status
}, { timestamps: true });

module.exports = mongoose.model("Reservation", reservationSchema);

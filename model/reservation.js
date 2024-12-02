const mongoose = require("mongoose")

const reservationSchema = new mongoose.Schema({
  userName: { type: String, required: true },
  reservationDate: { type: Date, required: true },
  time: { type: String, required: true },
  status: {
    type: String,
    enum: ["pending", "done", "cancelled"],
    default: "pending",
  },
})

module.exports = mongoose.model("Reservation", reservationSchema)

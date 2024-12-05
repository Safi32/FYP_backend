const mongoose = require("mongoose")

const reservationSchema = new mongoose.Schema({
  tableNumber: {
    type: Number,
    required: true,
  },
  noOfPersons: {
    type: Number,
    required: true,
  },
  date: {
    type: String,
    required: true,
  },
  time: {
    type: String,
    required: true,
  },
})

module.exports = mongoose.model("Reservation", reservationSchema)

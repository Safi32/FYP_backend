const mongoose = require("mongoose")

const reservationSchema = new mongoose.Schema({
  username: { type: String, required: true },
  systemDate: { type: Date, default: Date.now },
  tableNumber: { type: Number, required: true },
  noOfPersons: { type: Number, required: true },
})

// Virtual to format date and time
reservationSchema.virtual("formattedDate").get(function () {
  const options = { timeZone: "UTC" }
  const date = this.systemDate.toLocaleDateString("en-GB", options) // Format: DD/MM/YYYY
  const time = this.systemDate.toLocaleTimeString("en-US", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
    ...options,
  }) // Format: 3:20 AM
  return { date, time }
})

// Ensure virtuals are included when converting documents to JSON
reservationSchema.set("toJSON", { virtuals: true })

module.exports = mongoose.model("Reservation", reservationSchema)

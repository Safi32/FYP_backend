const Reservation = require("../model/reservation")
const User = require("../model/index")

const createReservation = async (req, res) => {
  try {
    const { tableNumber, noOfPersons, date, time } = req.body

    // Validate required fields
    if (!tableNumber || !noOfPersons || !date || !time) {
      return res.status(400).json({
        error:
          "All fields (userId, tableNumber, noOfPersons, date, time) are required",
      })
    }

    // Create a new reservation
    const newReservation = new Reservation({
      tableNumber,
      noOfPersons,
      date, // Pass the date
      time, // Pass the time
    })

    const savedReservation = await newReservation.save()

    // Send the response
    res.status(201).json({
      message: "Reservation created successfully",
      reservation: {
        tableNumber: savedReservation.tableNumber,
        noOfPersons: savedReservation.noOfPersons,
        date: savedReservation.date,
        time: savedReservation.time,
      },
    })
  } catch (error) {
    console.error("Error creating reservation:", error)
    res.status(500).json({ error: error.message })
  }
}

module.exports = { createReservation }

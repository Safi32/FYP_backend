const Reservation = require("../model/reservation")
const User = require("../model/index")

const createReservation = async (req, res) => {
  try {
    const { userId, tableNumber, noOfPersons } = req.body

    if (!userId || !tableNumber || !noOfPersons) {
      return res.status(400).json({ error: "All fields are required" })
    }

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ error: "User not found" })
    }

    const newReservation = new Reservation({
      username: user.username,
      tableNumber,
      noOfPersons,
    })

    const savedReservation = await newReservation.save()

    const reservationJSON = savedReservation.toJSON()

    res.status(201).json({
      message: "Reservation created successfully",
      reservation: {
        username: reservationJSON.username,
        tableNumber: reservationJSON.tableNumber,
        noOfPersons: reservationJSON.noOfPersons,
        date: reservationJSON.formattedDate.date,
        time: reservationJSON.formattedDate.time,
      },
    })
  } catch (error) {
    console.error("Error creating reservation:", error)
    res.status(500).json({ error: error.message })
  }
}

module.exports = { createReservation }

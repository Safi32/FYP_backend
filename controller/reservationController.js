const Reservation = require("../model/reservation")

// Mark Reservation as Done
exports.markAsDone = async (req, res) => {
  const { reservationId } = req.params

  try {
    const reservation = await Reservation.findById(reservationId)

    if (!reservation) {
      return res.status(404).json({ message: "Reservation not found" })
    }

    reservation.status = "done"
    await reservation.save()

    res.status(200).json({ message: "Reservation marked as done", reservation })
  } catch (error) {
    res.status(500).json({ message: "An error occurred", error: error.message })
  }
}

// Cancel Reservation
exports.cancelReservation = async (req, res) => {
  const { reservationId } = req.params

  try {
    const reservation = await Reservation.findById(reservationId)

    if (!reservation) {
      return res.status(404).json({ message: "Reservation not found" })
    }

    reservation.status = "cancelled"
    await reservation.save()

    res.status(200).json({ message: "Reservation cancelled", reservation })
  } catch (error) {
    res.status(500).json({ message: "An error occurred", error: error.message })
  }
}

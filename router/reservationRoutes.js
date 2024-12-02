const express = require("express")
const router = express.Router()
const {
  markAsDone,
  cancelReservation,
} = require("../controller/reservationController")

// Mark reservation as done
router.patch("/:reservationId/done", markAsDone)

// Cancel reservation
router.patch("/:reservationId/cancel", cancelReservation)

module.exports = router

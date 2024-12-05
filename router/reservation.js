const express = require("express")
const {
  createReservation,
  getUsernameById,
} = require("../controller/reservation")

const router = express.Router()
router.post("/", createReservation)

module.exports = router

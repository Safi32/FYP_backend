const express = require("express")
const { createReservation } = require("../controller/reservation")

const router = express.Router()
router.post("/", createReservation)

module.exports = router

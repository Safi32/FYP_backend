const express = require("express")
const router = express.Router()
const { createRestaurant } = require("../controller/restaurant.js")

router.post("/restaurant", createRestaurant)

module.exports = router

const express = require("express")
const router = express.Router()
const { createRestaurant } = require("../controller/restaurant.js")
const { uploadPictures } = require("../middleware/restaurant.js")

router.post("/restaurant", uploadPictures, createRestaurant)

module.exports = router

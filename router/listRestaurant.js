const express = require("express")
const multer = require("multer")
const { registerRestaurant } = require("../controller/listRestaurant")

const router = express.Router()

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/")
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname)
  },
})

const upload = multer({ storage })

module.exports = upload

// Routes
router.post("/", upload.array("pictures", 4), registerRestaurant)

module.exports = router

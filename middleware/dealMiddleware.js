const express = require("express")
const multer = require("multer")
const {
  addDeal,
  getDeals,
  deleteDeal,
  updateDeal,
} = require("../controller/dealController")

const router = express.Router()

// Configure multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/") // Save images in the "uploads" folder
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`) // Create unique filenames
  },
})

const upload = multer({ storage })

// Routes
router.post("/add", upload.single("image"), addDeal) // Add a deal with image
router.get("/", getDeals) // Get all deals
router.delete("/delete/:id", deleteDeal) // Delete a deal
router.put("/update/:id", upload.single("image"), updateDeal) // Update a deal with image

module.exports = router

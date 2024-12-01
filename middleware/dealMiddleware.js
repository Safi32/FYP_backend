const express = require("express")
const multer = require("multer")
const {
  addDeal,
  getDeals,
  deleteDeal,
  updateDeal,
} = require("../controller/dealController")

const router = express.Router()

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/")
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`)
  },
})

const upload = multer({ storage })

router.post("/add", upload.single("image"), addDeal)
router.get("/", getDeals)
router.delete("/delete/:id", deleteDeal)
router.put("/update/:id", upload.single("image"), updateDeal)

module.exports = router

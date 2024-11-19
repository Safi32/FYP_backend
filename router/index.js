const express = require("express")
const router = express.Router()
const {
  createNewUser,
  loginUser,
  getProfile,
  generateOTP,
  verifyOTP,
} = require("../controller/index")
const authenticateToken = require("../middleware/index")

router.post("/signup", createNewUser)
router.post("/login", loginUser)
router.post("/otp", generateOTP)
router.post("/verify", verifyOTP)
router.get("/profile", authenticateToken, getProfile)

module.exports = router

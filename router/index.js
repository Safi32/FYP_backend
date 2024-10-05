const express = require("express")
const router = express.Router()
const {
  createNewUser,
  loginUser,
  authenticateToken,
  getProfile,
  generateOTP,
  verifyOTP,
} = require("../controller/index")

router
  .post("/signup", createNewUser)
  .post("/login", loginUser)
  .post("/otp", generateOTP)
  .post("/verify", verifyOTP)
router.get("/profile", authenticateToken, getProfile)

module.exports = router

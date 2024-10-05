const express = require("express")
const router = express.Router()
const {
  createNewUser,
  loginUser,
  authenticateToken,
  getProfile,
  generateOTP,
} = require("../controller/index")

router
  .post("/signup", createNewUser)
  .post("/login", loginUser)
  .post("/otp", generateOTP)
router.get("/profile", authenticateToken, getProfile)

module.exports = router

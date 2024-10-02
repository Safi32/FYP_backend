const express = require("express")
const router = express.Router()
const {
  createNewUser,
  loginUser,
  authenticateToken,
  getProfile,
} = require("../controller/index")

router.post("/signup", createNewUser).post("/login", loginUser)
router.get("/profile", authenticateToken, getProfile)

module.exports = router

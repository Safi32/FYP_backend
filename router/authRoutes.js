const express = require("express");
const { registerUser, loginUser, logoutUser } = require("../controller/authController");

const router = express.Router();


router.post("/login", loginUser);       // Login user
router.post("/logout", logoutUser);     // Logout user (blacklist the token)

module.exports = router;

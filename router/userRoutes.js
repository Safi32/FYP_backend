const express = require("express");
const { sendOtp, verifyOtp, resetPassword, loginUser, logoutUser } = require("../controller/userController");

const router = express.Router();

// Login and Logout
router.post("/login", loginUser);
router.post("/logout", logoutUser);

// Forgot Password
router.post("/forgot-password/send-otp", sendOtp); // Send OTP
router.post("/forgot-password/verify-otp", verifyOtp); // Verify OTP
router.post("/forgot-password/reset", resetPassword); // Reset password

module.exports = router;

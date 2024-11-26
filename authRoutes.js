const express = require("express");
const { registerUser, loginUser } = require("../controller/authController");

const router = express.Router();


router.post("/login", loginUser);       // Login user

module.exports = router;

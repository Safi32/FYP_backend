const bcrypt = require("bcrypt")
const jwt = require("jsonwebtoken")
const User = require("../model/index")
const nodemailer = require("nodemailer")
require("dotenv").config()

const JWT_SECRET = "DineDeal"

async function createNewUser(req, res) {
  const body = req.body
  if (
    !body ||
    !body.email ||
    !body.phoneNumber ||
    !body.password ||
    !body.confirmPassword
  ) {
    return res.status(400).json({
      message: "All fields are required",
    })
  }

  if (body.password !== body.confirmPassword) {
    return res.status(400).json({
      message: "Passwords do not match",
    })
  }

  try {
    const existingUser = await User.findOne({ email: body.email })
    if (existingUser) {
      return res.status(400).json({
        message: "Email already exists",
      })
    }

    const hashedPassword = await bcrypt.hash(body.password, 10)
    const newUser = new User({
      email: body.email,
      phoneNumber: body.phoneNumber,
      password: hashedPassword,
    })

    await newUser.save()
    return res.status(201).json({
      message: "User Created Successfully",
    })
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    })
  }
}

async function loginUser(req, res) {
  const { email, password } = req.body

  if (!email || !password) {
    return res.status(400).json({ message: "Email and Password are required" })
  }

  try {
    const existingUser = await User.findOne({ email })
    if (!existingUser) {
      return res.status(404).json({ message: "User not found" })
    }

    const isPasswordValid = await bcrypt.compare(
      password,
      existingUser.password
    )
    if (!isPasswordValid) {
      return res.status(401).json({ message: "Invalid credentials" })
    }

    const token = jwt.sign({ id: existingUser._id }, JWT_SECRET, {
      expiresIn: "1h",
    })
    return res.status(200).json({ message: "Login successful", token })
  } catch (error) {
    return res.status(500).json({ message: "Error during login", error })
  }
}

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"]
  const token = authHeader && authHeader.split(" ")[1]

  if (!token) {
    return res.status(401).json({ message: "Token is required" })
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ message: "Invalid token" })
    }
    req.user = user
    next()
  })
}

async function getProfile(req, res) {
  try {
    const specificUser = await User.findById(req.user.id)

    if (!specificUser) {
      return res.status(404).json({ message: "User not found" })
    }

    return res.status(200).json({
      message: "User profile data retrieved successfully",
      user: specificUser,
    })
  } catch (error) {
    return res.status(500).json({ message: "Error fetching user", error })
  }
}

const generateOTP = (req, res) => {
  const otp = Math.floor(1000 + Math.random() * 9000)

  const { email } = req.body
  if (!email) {
    return res.status(400).json({
      success: false,
      message: "Email is required",
    })
  }
  const transporater = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.Email_User,
      pass: process.env.Email_Password,
    },
  })
  const mailOptions = {
    from: process.env.Email_User,
    to: email,
    subject: "Password Reset OTP",
    text: `Your OTP code for password reset is : ${otp}`,
  }
  transporater.sendMail(mailOptions, (error, info) => {
    if (error) {
      return res.status(500).json({
        success: false,
        message: "Failed to send OTP",
        error,
      })
    }
    res.status(200).json({
      success: true,
      message: `OTP sent successfully to ${email}`,
    })
  })
}

module.exports = {
  createNewUser,
  loginUser,
  authenticateToken,
  getProfile,
  generateOTP,
}

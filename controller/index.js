const bcrypt = require("bcrypt")
const jwt = require("jsonwebtoken")
const User = require("../model/index")
const nodemailer = require("nodemailer")
require("dotenv").config()

const JWT_SECRET = process.env.JWT_SECRET

// const createNewUser = async (req, res) => {
//   const { username, email, password, confirmPassword } = req.body

//   if (!username || !email || !password || !confirmPassword) {
//     return res.status(400).json({ message: "All fields are required" })
//   }

//   if (password !== confirmPassword) {
//     return res.status(400).json({ message: "Passwords do not match" })
//   }

//   try {
//     const existingUser = await User.findOne({ email })
//     if (existingUser) {
//       return res.status(400).json({ message: "Email already exists" })
//     }

//     const hashedPassword = await bcrypt.hash(password, 10)
//     const newUser = new User({ username, email, password: hashedPassword })

//     const savedUser = await newUser.save()

//     // Return the `ObjectId` and username in the response
//     return res.status(201).json({
//       message: "User created successfully",
//       user: {
//         id: savedUser._id,
//         username: savedUser.username,
//       },
//     })
//   } catch (error) {
//     console.error("Error creating user:", error.message)
//     return res
//       .status(500)
//       .json({ message: "Server error", error: error.message })
//   }
// }

const createNewUser = async (req, res) => {
  const { username, email, password, confirmPassword } = req.body

  if (!username || !email || !password || !confirmPassword) {
    return res.status(400).json({ message: "All fields are required" })
  }

  if (password !== confirmPassword) {
    return res.status(400).json({ message: "Passwords do not match" })
  }

  try {
    const existingEmail = await User.findOne({ email })
    if (existingEmail) {
      return res.status(400).json({ message: "Email already exists" })
    }

    const existingUsername = await User.findOne({ username })
    if (existingUsername) {
      return res.status(400).json({ message: "Username already exists" })
    }

    const hashedPassword = await bcrypt.hash(password, 10)
    const newUser = new User({ username, email, password: hashedPassword })

    const savedUser = await newUser.save()

    // Return ObjectId and username after signup
    return res.status(201).json({
      message: "User created successfully",
      userId: savedUser._id,
      username: savedUser.username,
    })
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server error", error: error.message })
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
    return res
      .status(500)
      .json({ message: "Error during login", error: error.message })
  }
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
    return res
      .status(500)
      .json({ message: "Error fetching user", error: error.message })
  }
}

async function generateOTP(req, res) {
  const otp = Math.floor(1000 + Math.random() * 9000).toString()
  const { email } = req.body

  if (!email) {
    return res
      .status(400)
      .json({ success: false, message: "Email is required" })
  }

  try {
    const user = await User.findOneAndUpdate(
      { email },
      { otp, otpCreatedAt: Date.now() },
      { new: true }
    )

    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" })
    }

    const transporter = nodemailer.createTransport({
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
      text: `Your OTP code for password reset is: ${otp}`,
    }

    transporter.sendMail(mailOptions, (error) => {
      if (error) {
        return res
          .status(500)
          .json({ success: false, message: "Failed to send OTP", error })
      }
      res
        .status(200)
        .json({ success: true, message: `OTP sent successfully to ${email}` })
    })
  } catch (error) {
    return res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message })
  }
}

const verifyOTP = async (req, res) => {
  const { otp } = req.body

  if (!otp) {
    return res.status(400).json({ success: false, message: "OTP is required" })
  }

  try {
    const user = await User.findOne({ otp })

    if (!user) {
      return res
        .status(400)
        .json({ success: false, message: "OTP not found or expired" })
    }

    user.otp = undefined
    await user.save()

    return res
      .status(200)
      .json({ success: true, message: "OTP verified successfully" })
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Server error during OTP verification",
      error: error.message,
    })
  }
}

module.exports = {
  createNewUser,
  loginUser,
  getProfile,
  generateOTP,
  verifyOTP,
}

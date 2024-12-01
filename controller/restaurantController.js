const Restaurant = require("../model/restaurant")
const jwt = require("jsonwebtoken")
const bcrypt = require("bcryptjs")
const BlacklistedToken = require("../model/BlacklistedToken")

const loginRestaurant = async (req, res) => {
  try {
    const { email, password } = req.body

    const restaurant = await Restaurant.findOne({ email })
    if (!restaurant) {
      return res.status(404).json({ message: "Restaurant not found" })
    }

    const isMatch = await bcrypt.compare(password, restaurant.password)
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" })
    }

    const token = jwt.sign({ id: restaurant._id }, process.env.JWT_SECRET, {
      expiresIn: "1h",
    })
    res.status(200).json({ message: "Login successful", token })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

const logoutRestaurant = async (req, res) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "")
    if (!token) {
      return res.status(400).json({ message: "No token provided" })
    }

    const decoded = jwt.decode(token)
    const expiresAt = new Date(decoded.exp * 1000)

    const blacklistedToken = new BlacklistedToken({ token, expiresAt })
    await blacklistedToken.save()

    res.status(200).json({ message: "Logout successful. Token blacklisted." })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

module.exports = { loginRestaurant, logoutRestaurant }

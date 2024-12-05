const User = require("../../model/userModel")
const bcrypt = require("bcryptjs")
const jwt = require("jsonwebtoken")

const login = async (req, res) => {
  try {
    const { email, password } = req.body

    // Check if the user exists
    const user = await User.findOne({ email })
    if (!user) {
      return res.status(404).json({ message: "User not found." })
    }

    // Compare passwords
    const isPasswordMatch = await bcrypt.compare(password, user.password)
    if (!isPasswordMatch) {
      return res.status(401).json({ message: "Invalid email or password." })
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET || "safasjfda90qej3q03iofnq0o3nf-o23",
      { expiresIn: "1h" }
    )

    res.status(200).json({
      message: "Login successful.",
      token,
      user: {
        email: user.email,
        role: user.role,
        username: user.username,
      },
    })
  } catch (error) {
    console.error("Login Error:", error)
    res.status(500).json({ message: "Internal Server Error." })
  }
}

module.exports = { login }

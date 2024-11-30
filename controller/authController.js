const User = require("../model/User");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const BlacklistedToken = require("../model/BlacklistedToken");

// Login API
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate user email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Validate password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // Generate JWT
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "1h" });

    res.status(200).json({ message: "Login successful", token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Logout user and blacklist the token
const logoutUser = async (req, res) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "");
    if (!token) {
      return res.status(400).json({ message: "No token provided" });
    }

    // Decode the token to get expiration time
    const decoded = jwt.decode(token);
    if (!decoded || !decoded.exp) {
      return res.status(400).json({ message: "Invalid token" });
    }

    // Calculate expiration date and add to the blacklist
    const expiresAt = new Date(decoded.exp * 1000);
    const blacklistedToken = new BlacklistedToken({ token, expiresAt });
    await blacklistedToken.save();

    res.status(200).json({ message: "Logout successful. Token blacklisted." });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = {loginUser , logoutUser };

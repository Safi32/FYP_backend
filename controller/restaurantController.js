const Restaurant = require("../model/Restaurant");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const BlacklistedToken = require("../model/BlacklistedToken");

// Login Restaurant
const loginRestaurant = async (req, res) => {
  try {
    const { email, password } = req.body;

    const restaurant = await Restaurant.findOne({ email });
    if (!restaurant) {
      return res.status(404).json({ message: "Restaurant not found" });
    }

    const isMatch = await bcrypt.compare(password, restaurant.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign({ id: restaurant._id }, process.env.JWT_SECRET, { expiresIn: "1h" });
    res.status(200).json({ message: "Login successful", token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Logout Restaurant
const logoutRestaurant = async (req, res) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "");
    if (!token) {
      return res.status(400).json({ message: "No token provided" });
    }

    const decoded = jwt.decode(token);
    const expiresAt = new Date(decoded.exp * 1000);

    const blacklistedToken = new BlacklistedToken({ token, expiresAt });
    await blacklistedToken.save();

    res.status(200).json({ message: "Logout successful. Token blacklisted." });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Register a new restaurant
const registerRestaurant = async (req, res) => {
  try {
    const {
      name,
      phoneNumber,
      email,
      address,
      websiteURL,
      socialMediaLinks,
      restaurantType,
      operationalHours,
      minPriceRange,
      maxPriceRange,
      restaurantInfo,
      acceptPolicies,
      advanceReservationPeriod,
      restaurantFeatures,
      additionalInformation,
      password,
    } = req.body;

    // Validate required fields
    if (!acceptPolicies) {
      return res.status(400).json({ message: "Policies must be accepted to register." });
    }

    // Check if email already exists
    const existingRestaurant = await Restaurant.findOne({ email });
    if (existingRestaurant) {
      return res.status(400).json({ message: "Email is already registered." });
    }

    // Store uploaded image URLs
    const pictures = req.files.map((file) => file.path);

    // Create a new restaurant
    const restaurant = new Restaurant({
      name,
      phoneNumber,
      email,
      address,
      websiteURL,
      socialMediaLinks,
      restaurantType,
      operationalHours,
      minPriceRange,
      maxPriceRange,
      restaurantInfo,
      pictures,
      acceptPolicies,
      advanceReservationPeriod,
      restaurantFeatures,
      additionalInformation,
      password,
    });

    // Save restaurant to the database
    await restaurant.save();

    res.status(201).json({ message: "Restaurant registered successfully", restaurant });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { loginRestaurant, logoutRestaurant, registerRestaurant };

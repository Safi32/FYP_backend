const express = require("express");
const dotenv = require("dotenv");
const connectDB = require("./config/db");
const dealRoutes = require("./router/dealRoutes");
const authRoutes = require("./router/authRoutes");
const authMiddleware = require("./middleware/authMiddleware");

dotenv.config();

// Connect to MongoDB
connectDB();

const app = express();
app.use(express.json());

// Use routes
app.use("/api/deals", dealRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is listening on port ${PORT}`);
});
app.use("/uploads", express.static("uploads"));
app.use("/api/auth", authRoutes);
app.use("/api/protected", authMiddleware, (req, res) => {
  res.status(200).json({ message: "You are authorized!" });
});
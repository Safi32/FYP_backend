const express = require("express")
const dotenv = require("dotenv")
const connectDB = require("./config/db")
const userRoutes = require("./router/userRoutes")
const restaurantRoutes = require("./router/restaurantRoutes")
const dealRoutes = require("./router/dealRoutes")
const authMiddleware = require("./middleware/authMiddleware")

dotenv.config()
connectDB()

const app = express()
app.use(express.json())

app.use("/api/user", userRoutes)
app.use("/api/restaurant", restaurantRoutes)
app.use("/api/deals", dealRoutes)

const PORT = process.env.PORT || 3000

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`)
})

app.use("/uploads", express.static("uploads"))
app.use("/api/protected", authMiddleware, (req, res) => {
  res.status(200).json({ message: "You are authorized!" })
})

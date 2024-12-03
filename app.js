require("dotenv").config()
const express = require("express")
const connectDB = require("./config/db")
const cors = require("cors")
const app = express()
const userLogin = require("./router/index.js")
const userRoutes = require("./router/index")
const authMiddleware = require("./middleware/authMiddleware.js")
const dealRoutes = require("./router/dealRouters.js")
const listRestaurant = require("./router/listRestaurant.js")
const ApiError = require("./utils/ApiError.js")
const reservation = require("./router/reservation.js")

app.use(cors())
app.use(
  express.urlencoded({
    extended: false,
  })
)
app.use(express.json())
app.use("/", userLogin)
app.use("/api/user", userRoutes)
app.use("/reservation", reservation)
app.use("/uploads", express.static("uploads"))
app.use("/api/deals", dealRoutes)
app.use("/api/protected", authMiddleware, (req, res) => {
  res.status(200).json({ message: "You are authorized!" })
})
app.use("/listRestaurant", listRestaurant)
app.use((err, req, res, next) => {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({ message: err.message })
  }
  console.error(err)
  res.status(500).json({ message: "Internal Server Error" })
})

const PORT = process.env.PORT || 3000
connectDB()
app.listen(3000, "0.0.0.0", () => {
  console.log("Server is running on port 3000")
})
// const express = require("express")
// const dotenv = require("dotenv")
// const connectDB = require("./config/db")
// const userRoutes = require("./router/userRoutes")
// const restaurantRoutes = require("./router/restaurantRoutes")
// const dealRoutes = require("./router/dealRoutes")
// const authMiddleware = require("./middleware/authMiddleware")

// dotenv.config()
// connectDB()

// const app = express()
// app.use(express.json())

// const PORT = process.env.PORT || 3000

// app.listen(PORT, () => {
//   console.log(`Server is running on port ${PORT}`)
// })

// app.use("/uploads", express.static("uploads"))
// app.use("/api/protected", authMiddleware, (req, res) => {
//   res.status(200).json({ message: "You are authorized!" })
// })

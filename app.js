require("dotenv").config()
const express = require("express")
const db = require("./config/db")
const cors = require("cors")
const app = express()
const userRoutes = require("./router/index")
const { uploadPictures } = require("./middleware/restaurant.js")
const routers = require("./router/restaurant.js")

app.use(cors())
app.use(
  express.urlencoded({
    extended: false,
  })
)
app.use(express.json())
app.use("/", userRoutes)
app.use("/", routers)

const PORT = process.env.PORT || 3000
db.dbConnect()
app.listen(3000, "0.0.0.0", () => {
  console.log("Server is running on port 3000")
})

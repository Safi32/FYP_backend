require("dotenv").config()
const express = require("express")
const mongoose = require("mongoose")
const db = require("./config/db")
const app = express()
const userRoutes = require("./router/index")

app.use(
  express.urlencoded({
    extended: false,
  })
)
app.use(express.json())

app.use("/", userRoutes)

const PORT = process.env.PORT || 3000
db.dbConnect()
app.listen(PORT, () => console.log(`Server started at port ${PORT}`))

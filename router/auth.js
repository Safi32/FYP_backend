const express = require("express")
const { signUp } = require("../controller/auth/registerUser")
const { login } = require("../controller/auth/loginUser")

const upload = require("../middleware/multer")

const authRouter = express.Router()

// router.post("/signup", signUp)
authRouter.post("/signup", upload.array("images", 4), signUp)
authRouter.post("/login", login)

module.exports = authRouter

const User = require("../../model/userModel")
const bcrypt = require("bcryptjs")
const cloudinary = require("../../utils/cloudinary")

const signUp = async (req, res) => {
  try {
    const { email, password, role, username, ...rest } = req.body

    const validRoles = ["user", "restaurant", "superAdmin"]
    if (!validRoles.includes(role)) {
      return res.status(400).json({ message: "Invalid role specified." })
    }

    const existingUser = await User.findOne({ email })
    if (existingUser) {
      return res.status(400).json({ message: "Email already registered." })
    }

    const hashedPassword = await bcrypt.hash(password, 10)

    const userData = {
      email,
      password: hashedPassword,
      role,
    }

    if (role === "user" || role === "superAdmin") {
      userData.username = username
    }

    if (role === "superAdmin") {
      userData.phone = rest.phone
    }

    if (role === "restaurant") {
      Object.assign(userData, rest)

      if (req.files && req.files.length > 0) {
        const uploadPromises = req.files.map((file) =>
          cloudinary.uploader.upload(file.path, { folder: "restaurant_images" })
        )

        const uploadResults = await Promise.all(uploadPromises)
        userData.images = uploadResults.map((result) => result.secure_url)
      }
    } else {
      if (req.files && req.files.length > 0) {
        return res
          .status(400)
          .json({ message: "Image uploads are not allowed for this role." })
      }
    }

    const newUser = new User(userData)
    await newUser.save()

    res
      .status(201)
      .json({ message: "User registered successfully.", user: newUser })
  } catch (error) {
    console.error("Sign-Up Error:", error)
    res.status(500).json({ message: "Internal Server Error." })
  }
}

module.exports = { signUp }

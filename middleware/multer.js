const multer = require("multer")
const path = require("path")

// Multer Storage Configuration
const storage = multer.diskStorage({
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`)
  },
})

// File Validation (Only Images)
const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname)
  if (ext === ".jpg" || ext === ".jpeg" || ext === ".png" || ext === ".gif") {
    cb(null, true)
  } else {
    cb(new Error("Only images are allowed."), false)
  }
}

const upload = multer({
  storage,
  fileFilter,
})

module.exports = upload

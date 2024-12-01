const multer = require("multer")
const path = require("path")

// Configure multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/") // Ensure this folder exists
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9)
    cb(null, uniqueSuffix + path.extname(file.originalname)) // Generate unique file name
  },
})

// File type filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = ["image/jpeg", "image/jpg", "image/png"]
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true) // Accept the file
  } else {
    cb(new Error("Only .jpeg, .jpg, and .png files are allowed"), false) // Reject unsupported types
  }
}

// Multer configuration
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // Limit file size to 5MB
})

// Middleware for handling multiple file uploads
const uploadPictures = upload.array("pictures", 5) // Allow up to 5 images

// Export the middleware
module.exports = {
  uploadPictures,
}

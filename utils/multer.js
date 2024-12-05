const multer = require("multer")
const cloudinary = require("./cloudinary")

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "restaurants", // Folder name in Cloudinary
    allowed_formats: ["jpg", "png", "jpeg"], // Allowed file formats
  },
})

const upload = multer({ storage })

module.exports = upload

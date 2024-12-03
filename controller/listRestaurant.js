const Restaurant = require("../model/listRestaurant")
const uploadOnCloudinary = require("../utils/cloudinary")

const registerRestaurant = async (req, res) => {
  try {
    const {
      name,
      email,
      address,
      phoneNumber,
      websiteURL,
      socialMediaLinks = [],
      type = [],
      hours,
      minimumPriceRange,
      maximumPriceRange,
      information = [],
      acceptPolicies,
      advanceReservationDays,
      advanceReservationHours,
      features = [],
      additionalInformation,
    } = req.body

    let mediaGallery = []

    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const uploadResult = await uploadOnCloudinary(file.path)
        mediaGallery.push(uploadResult.secure_url)
      }
    }

    const newRestaurant = new Restaurant({
      name,
      email,
      address,
      phoneNumber,
      websiteURL,
      socialMediaLinks,
      type,
      hours,
      minimumPriceRange,
      maximumPriceRange,
      information,
      acceptPolicies,
      advanceReservationDays,
      advanceReservationHours,
      features,
      mediaGallery,
      additionalInformation,
    })

    await newRestaurant.save()

    res.status(201).json({
      message: "Restaurant registered successfully",
      restaurant: newRestaurant,
    })
  } catch (err) {
    res.status(500).json({ error: err.message })
    console.log("Request Body:", req.body)
    console.log("Request Files:", req.files)
  }
}

module.exports = { registerRestaurant }

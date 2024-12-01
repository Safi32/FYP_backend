const Restaurant = require("../model/restaurant")
const bcrypt = require("bcrypt")

exports.createRestaurant = async (req, res) => {
  try {
    const picturePaths = req.files ? req.files.map((file) => file.path) : []

    const hashedPassword = await bcrypt.hash(req.body.password, 10)

    const restaurant = new Restaurant({
      name: req.body.name,
      phoneNumber: req.body.phoneNumber,
      email: req.body.email,
      address: req.body.address,
      websiteURL: req.body.websiteURL,
      socialMediaLinks: req.body.socialMediaLinks,
      restaurantType: req.body.restaurantType,
      operationalHours: req.body.operationalHours,
      minPriceRange: req.body.minPriceRange,
      maxPriceRange: req.body.maxPriceRange,
      restaurantInfo: req.body.restaurantInfo,
      pictures: picturePaths,
      password: hashedPassword,
      acceptPolicies: req.body.acceptPolicies === "true",
      advanceReservationPeriod: {
        days: req.body.advanceReservationDays,
        hours: req.body.advanceReservationHours,
      },
      restaurantFeatures: req.body.restaurantFeatures,
      additionalInformation: req.body.additionalInformation,
    })

    await restaurant.save()
    res
      .status(201)
      .json({ message: "Restaurant created successfully", restaurant })
  } catch (error) {
    res.status(400).json({ error: error.message })
  }
}

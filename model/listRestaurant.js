const mongoose = require("mongoose")

const restaurantSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true },
    address: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    websiteURL: { type: String },
    socialMediaLinks: { type: Array, default: [] },
    restaurantType: { type: [String], default: [] },
    operationHours: { type: Number },
    minimumPriceRange: { type: Number },
    maximumPriceRange: { type: Number },
    restaurantInfo: { type: [String], default: [] },
    acceptPolicies: { type: String, enum: ["Yes", "No"], required: true },
    advanceReservationDays: { type: Number },
    advanceReservationHours: { type: Number },
    restaurantFeatures: { type: [String], default: [] },
    mediaGallery: { type: [String], default: [] },
    additionalInformation: { type: String },
  },
  { timestamps: true }
)

module.exports = mongoose.model(
  "Restaurant",
  restaurantSchema,
  "restaurants_data"
)

const mongoose = require("mongoose")

const restaurantSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
    },
    phoneNumber: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
    },
    address: {
      type: String,
      required: true,
    },
    websiteURL: {
      type: String,
    },
    socialMediaLinks: [
      {
        type: String,
      },
    ],
    restaurantType: [
      {
        type: String,
      },
    ],
    operationalHours: {
      type: String,
    },
    minPriceRange: {
      type: Number,
    },
    maxPriceRange: {
      type: Number,
    },
    restaurantInfo: [
      {
        type: String,
      },
    ],
    pictures: [
      {
        type: String,
      },
    ],
    acceptPolicies: {
      type: Boolean,
      required: true,
    },
    advanceReservationPeriod: {
      days: {
        type: Number,
        default: 0,
      },
      hours: { type: Number, default: 0 },
    },
    restaurantFeatures: [
      {
        type: String,
      },
    ],
    additionalInformation: {
      type: String,
    },
    password: {
      type: String,
      required: true,
      minlength: 6,
    },
  },
  { collection: "restaurants_data" }
)

module.exports = mongoose.model("Restaurant", restaurantSchema)

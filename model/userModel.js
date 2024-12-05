const mongoose = require("mongoose")
const bcrypt = require("bcryptjs")

const userModel = new mongoose.Schema(
  {
    role: {
      type: String,
      enum: ["user", "restaurant", "superAdmin"],
      required: true,
    },
    // Common fields
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },

    // Fields for 'user'
    username: {
      type: String,
      required: function () {
        return this.role === "user"
      },
    },

    // Fields for 'restaurant'
    restaurantName: {
      type: String,
      required: function () {
        return this.role === "restaurant"
      },
    },
    restaurantAddress: {
      type: String,
      required: function () {
        return this.role === "restaurant"
      },
    },
    phoneNumber: {
      type: String,
      required: function () {
        return this.role === "restaurant"
      },
    },
    socialMediaLinks: [{ type: String }],
    category: { type: String },
    websiteUrl: { type: String },
    restaurantType: [{ type: String }],
    operationalDetails: [{ type: String }],
    acceptsReservations: { type: Boolean },
    advanceReservation: {
      daysBefore: { type: Number },
      hoursBefore: { type: Number },
    },
    features: [{ type: String }],
    images: [{ type: String }],
    additionalNotes: { type: String },

    // Fields for 'superAdmin'
    phone: {
      type: String,
      required: function () {
        return this.role === "superAdmin"
      },
    },
    username: {
      type: String,
      required: function () {
        return this.role === "superAdmin"
      },
    },
  },
  { timestamps: true }
)

module.exports = mongoose.model("users", userModel)

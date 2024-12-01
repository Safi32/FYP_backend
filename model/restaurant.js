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

// module.exports = mongoose.model("Restaurant", restaurantSchema)
// const mongoose = require("mongoose");
// const bcrypt = require("bcryptjs");

// const restaurantSchema = new mongoose.Schema({
//   email: { type: String, required: true, unique: true },
//   password: { type: String, required: true },
// }, { timestamps: true });

// restaurantSchema.pre("save", async function (next) {
//   if (!this.isModified("password")) return next();
//   const salt = await bcrypt.genSalt(10);
//   this.password = await bcrypt.hash(this.password, salt);
//   next();
// });

// module.exports = mongoose.model("Restaurant", restaurantSchema, "restaurants_data");

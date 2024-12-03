const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const restaurantSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  address: { type: String, required: true },
  websiteURL: { type: String },
  socialMediaLinks: { type: [String], default: [] },
  restaurantType: { type: [String], required: true },
  operationalHours: { type: String, required: true },
  minPriceRange: { type: Number, required: true },
  maxPriceRange: { type: Number, required: true },
  restaurantInfo: { type: [String], default: [] },
  pictures: { type: [String], default: [] },
  acceptPolicies: { type: Boolean, required: true },
  advanceReservationPeriod: { type: Object, default: {} },
  restaurantFeatures: { type: [String], default: [] },
  additionalInformation: { type: String, default: "" },
  password: { type: String, required: true },
}, { timestamps: true });

// Hash password before saving
restaurantSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

module.exports = mongoose.model("Restaurant", restaurantSchema, "restaurants_data");

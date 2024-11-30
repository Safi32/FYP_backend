const express = require("express");
const { loginRestaurant, logoutRestaurant } = require("../controller/restaurantController");

const router = express.Router();

router.post("/login", loginRestaurant);
router.post("/logout", logoutRestaurant);

module.exports = router;

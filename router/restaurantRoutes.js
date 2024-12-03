const express = require("express");
const { loginRestaurant, logoutRestaurant, registerRestaurant } = require("../controller/restaurantController");
const upload = require("../config/multer");

const router = express.Router();

router.post("/login", loginRestaurant);
router.post("/logout", logoutRestaurant);
router.post("/register", upload.array("pictures", 5), registerRestaurant); // Max 5 pictures

module.exports = router;

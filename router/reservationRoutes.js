const express = require("express");
const { createReservation, updateReservationStatus, getReservationsForRestaurant } = require("../controller/reservationController");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// User creates a reservation
router.post("/", authMiddleware(["user"]), async (req, res, next) => {
  try {
    await createReservation(req, res);
  } catch (err) {
    next(err);
  }
});

// Restaurant updates reservation status
router.put("/:reservationId", authMiddleware(["restaurant"]), async (req, res, next) => {
  try {
    await updateReservationStatus(req, res);
  } catch (err) {
    next(err);
  }
});

// Restaurant fetches reservations
router.get("/", authMiddleware(["restaurant"]), async (req, res, next) => {
  try {
    await getReservationsForRestaurant(req, res);
  } catch (err) {
    next(err);
  }
});

module.exports = router;

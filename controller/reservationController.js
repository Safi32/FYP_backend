const Reservation = require("../model/Reservation");
const Restaurant = require("../model/Restaurant");

// User makes a reservation
const createReservation = async (req, res) => {
  try {
    const { restaurantId, username, date, persons, tableNumber } = req.body;

    // Validate restaurant exists
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ message: "Restaurant not found" });
    }

    // Create reservation
    const reservation = new Reservation({
      userId: req.user.id, // Authenticated user ID
      restaurantId,
      username,
      date,
      persons,
      tableNumber,
    });

    await reservation.save();
    res.status(201).json({ message: "Reservation request sent", reservation });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Restaurant accepts or rejects a reservation
const updateReservationStatus = async (req, res) => {
  try {
    const { reservationId } = req.params;
    const { status } = req.body;

    if (!["Accepted", "Rejected"].includes(status)) {
      return res.status(400).json({ message: "Invalid status" });
    }

    // Update reservation status
    const reservation = await Reservation.findById(reservationId);
    if (!reservation) {
      return res.status(404).json({ message: "Reservation not found" });
    }

    // Check if the reservation belongs to the restaurant
    if (reservation.restaurantId.toString() !== req.user.id) {
      return res.status(403).json({ message: "Unauthorized" });
    }

    reservation.status = status;
    await reservation.save();

    res.status(200).json({ message: `Reservation ${status.toLowerCase()}`, reservation });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Fetch reservations for a restaurant
const getReservationsForRestaurant = async (req, res) => {
  try {
    const reservations = await Reservation.find({ restaurantId: req.user.id }).populate("userId", "username");
    res.status(200).json(reservations);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { createReservation, updateReservationStatus, getReservationsForRestaurant };

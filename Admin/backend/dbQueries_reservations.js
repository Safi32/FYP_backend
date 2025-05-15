const db = require('./dbConnection'); // Adjust if needed

// Get reservations by restaurant ID and include the user's name
async function getReservationsByRestaurantId(restaurantId) {
  const query = `
  SELECT r.*, 
         u.username AS userName,
         SUBSTRING(r.reservationDate, 1, 10) AS reservationDate
  FROM reservations r
  LEFT JOIN users u ON r.userId = u.id
  WHERE r.restaurantId = ?
`;

  
  const [rows] = await db.execute(query, [restaurantId]);
  return rows;
}

// Get all reservations and include the user's name
async function getAllReservations() {
  const query = `
    SELECT r.*,
           u.username AS userName,
           SUBSTRING(r.reservationDate, 1, 10) AS reservationDate
    FROM reservations r
    LEFT JOIN users u ON r.userId = u.id
  `;

  const [rows] = await db.execute(query);
  return rows;
}

module.exports = { getReservationsByRestaurantId, getAllReservations };


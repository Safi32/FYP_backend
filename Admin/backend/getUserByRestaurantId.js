const db = require('../dbConnection');

async function getUserByRestaurantId(restaurantId) {
  try {
    const [rows] = await db.query(
      `SELECT u.email 
       FROM users u 
       JOIN restaurant r ON u.id = r.userId 
       WHERE r.id = ?`,
      [restaurantId]
    );

    return rows.length > 0 ? rows[0].email : null;
  } catch (error) {
    console.error('Error fetching email by restaurant ID:', error.message);
    throw error;
  }
}

module.exports = getUserByRestaurantId;
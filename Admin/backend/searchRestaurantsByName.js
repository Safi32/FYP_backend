const db = require('../dbConnection');

async function searchRestaurantsByName(name) {
  try {
    let query = `
      SELECT restaurant.*, users.email, users.username
      FROM restaurant
      JOIN users ON restaurant.userId = users.id
      WHERE restaurant.restaurantName LIKE ?
    `;

    const [rows] = await db.query(query, [`%${name}%`]);
    return rows;
  } catch (error) {
    console.error('Error searching restaurants by name:', error.message);
    throw error;
  }
}

module.exports = searchRestaurantsByName;
const db = require('../dbConnection');

async function getRestaurants(status = null) {
  try {
    let query = `
      SELECT restaurant.*, users.email , users.username
      FROM restaurant 
      JOIN users ON restaurant.userId = users.id
    `;
    let values = [];

    if (status !== null) {
      query += ' WHERE restaurant.status = ?';
      values.push(status);
    }

    const [rows] = await db.query(query, values);
    return rows;
  } catch (error) {
    console.error('Error fetching restaurants:', error.message);
    throw error;
  }
}

module.exports = getRestaurants;
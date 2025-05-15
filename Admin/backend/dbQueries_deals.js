const db = require('./dbConnection'); // or correct path to your DB connection file

// Fetch deals by restaurant ID
async function getDealsByRestaurantId(restaurant_id) {
  const query = 'SELECT * FROM deals WHERE restaurant_id = ?';
  const [rows] = await db.execute(query, [restaurant_id]);
  return rows;
}

module.exports = { getDealsByRestaurantId };

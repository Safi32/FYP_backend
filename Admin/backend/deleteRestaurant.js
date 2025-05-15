const db = require('../dbConnection');

async function deleteRestaurant(restaurantId) {
  try {
    const [result] = await db.query('DELETE FROM restaurant WHERE id = ?', [restaurantId]);
    return result.affectedRows > 0;
  } catch (error) {
    console.error('Error deleting restaurant:', error.message);
    throw error;
  }
}

module.exports = deleteRestaurant;
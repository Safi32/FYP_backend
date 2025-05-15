const db = require('../dbConnection');

// ✅ Get user by username (only if roleId = 1)
async function getUserByUsername(username) {
  try {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE username LIKE ? AND roleId = 1',
      [`%${username}%`]
    );
    return rows;
  } catch (error) {
    console.error('Error fetching user by username:', error.message);
    throw error;
  }
}

module.exports = getUserByUsername;
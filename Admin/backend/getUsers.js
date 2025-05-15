const db = require('../dbConnection');

// ✅ Get all users with roleId = 1
async function getUsers() {
  try {
    const [rows] = await db.query('SELECT * FROM users WHERE roleId = 1');
    return rows;
  } catch (error) {
    console.error('Error fetching users:', error.message);
    throw error;
  }
}

module.exports = getUsers;
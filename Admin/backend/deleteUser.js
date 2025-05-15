const db = require('../dbConnection');

// ✅ Delete a user by ID (only if roleId = 1)
async function deleteUser(userId) {
  try {
    const [result] = await db.query(
      'DELETE FROM users WHERE id = ?',
      [userId]
    );
    return result.affectedRows > 0; // Returns true if a row was deleted
  } catch (error) {
    console.error('Error deleting user:', error.message);
    throw error;
  }
}

module.exports = deleteUser;
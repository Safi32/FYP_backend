// dbQueries_dealsCategory.js
const db = require('./dbConnection');
const cloudinary = require('./cloudinaryConfig');

// Get all deal categories
const getAllDealCategories = async () => {
  const [rows] = await db.query('SELECT * FROM dealscategory');
  return rows;
};

// Add a new deal category
const addDealCategory = async (categoryName, imageFile) => {
  const now = new Date();
  let imageUrl = null;

  if (imageFile) {
    const result = await cloudinary.uploader.upload(imageFile.path);
    imageUrl = result.secure_url;
  }

  const [result] = await db.query(
    'INSERT INTO dealscategory (category_name, image, createdAt, updatedAt) VALUES (?, ?, ?, ?)',
    [categoryName, imageUrl, now, now]
  );
  return result.insertId;
};

// Delete a deal category by ID
const deleteDealCategory = async (id) => {
  const [result] = await db.query('DELETE FROM dealscategory WHERE id = ?', [id]);
  return result.affectedRows > 0;
};

// Update a deal category
const updateDealCategory = async (id, categoryName, imageFile) => {
  const now = new Date();
  let imageUrl = null;

  if (imageFile) {
    const result = await cloudinary.uploader.upload(imageFile.path);
    imageUrl = result.secure_url;
  }

  const [result] = await db.query(
    'UPDATE dealscategory SET category_name = ?, image = ?, updatedAt = ? WHERE id = ?',
    [categoryName, imageUrl, now, id]
  );
  return result.affectedRows > 0;
};

module.exports = {
  getAllDealCategories,
  addDealCategory,
  deleteDealCategory,
  updateDealCategory,
};

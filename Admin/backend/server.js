const express = require('express');
const cors = require('cors');
const multer = require('multer');
const {
  getRestaurants,
  searchRestaurantsByName,
  deleteRestaurant,
  addRestaurant,
  updateRestaurant,
  getUserByRestaurantId,
} = require('./dbQueries_restaurant');

const { getUsers, getUserByUsername, deleteUser } = require('./dbQueries_user');

const { getReservationsByRestaurantId, getAllReservations} = require('./dbQueries_reservations');

const { getDealsByRestaurantId } = require('./dbQueries_deals');

const {
  getAllDealCategories,
  addDealCategory,
  deleteDealCategory,
  updateDealCategory,
} = require('./dbQueries_dealsCategory');

const app = express();
app.use(cors());
app.use(express.json());
const PORT = process.env.PORT || 3000;

const upload = multer({ dest: 'uploads/' });

app.use(express.json());

// ✅ Get all deal categories
app.get('/deal-categories', async (req, res) => {
  try {
    const categories = await getAllDealCategories();
    res.json(categories);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching deal categories', error: error.message });
  }
});

// ✅ Add a new deal category
app.post('/deal-categories', upload.single('image'), async (req, res) => {
  const { category_name } = req.body;
  if (!category_name) {
    return res.status(400).json({ message: 'Category name is required' });
  }

  try {
    const id = await addDealCategory(category_name, req.file);
    res.status(201).json({ message: 'Deal category added', id });
  } catch (error) {
    res.status(500).json({ message: 'Error adding deal category', error: error.message });
  }
});

// ✅ Delete a deal category
app.delete('/deal-categories/:id', async (req, res) => {
  try {
    const success = await deleteDealCategory(req.params.id);
    if (success) {
      res.json({ message: 'Deal category deleted' });
    } else {
      res.status(404).json({ message: 'Deal category not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error deleting deal category', error: error.message });
  }
});

// ✅ Update a deal category
app.put('/deal-categories/:id', upload.single('image'), async (req, res) => {
  const { category_name } = req.body;
  if (!category_name) {
    return res.status(400).json({ message: 'Category name is required' });
  }

  try {
    const success = await updateDealCategory(req.params.id, category_name, req.file);
    if (success) {
      res.json({ message: 'Deal category updated' });
    } else {
      res.status(404).json({ message: 'Deal category not found or no changes made' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error updating deal category', error: error.message });
  }
});

// ✅ Get all restaurants (optional status filter)
app.get('/restaurants', async (req, res) => {
  const { status } = req.query;
  try {
    const restaurants = await getRestaurants(status);
    res.json(restaurants);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching restaurants', error: error.message });
  }
});

// ✅ Search restaurants by name
app.get('/restaurants/search/:name', async (req, res) => {
  try {
    const restaurants = await searchRestaurantsByName(req.params.name);
    res.json(restaurants);
  } catch (error) {
    res.status(500).json({ message: 'Error searching restaurants', error: error.message });
  }
});

// ✅ Delete a restaurant by ID
app.delete('/restaurants/:restaurantId', async (req, res) => {
  try {
    const isDeleted = await deleteRestaurant(req.params.restaurantId);
    if (isDeleted) {
      res.json({ message: 'Restaurant deleted successfully' });
    } else {
      res.status(404).json({ message: 'Restaurant not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error deleting restaurant', error: error.message });
  }
});

// ✅ Get all users with roleId = 1
app.get('/users', async (req, res) => {
  try {
    res.json(await getUsers());
  } catch (error) {
    res.status(500).json({ message: 'Error fetching users', error: error.message });
  }
});

// ✅ Get user by username with roleId = 1
app.get('/users/search/:username', async (req, res) => {
  try {
    res.json(await getUserByUsername(req.params.username));
  } catch (error) {
    res.status(500).json({ message: 'Error fetching user by username', error: error.message });
  }
});

// ✅ Delete a user by ID (only roleId = 1)
app.delete('/users/:userId', async (req, res) => {
  try {
    const isDeleted = await deleteUser(req.params.userId);
    if (isDeleted) {
      res.json({ message: 'User deleted successfully' });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error deleting user', error: error.message });
  }
});

// ✅ Update restaurant by ID (update restaurantName and status)
app.put('/restaurants/:restaurantId', async (req, res) => {
  const { restaurantId } = req.params;
  const { restaurantName, status } = req.body;

  const validStatuses = ['Pending', 'Accepted', 'Declined'];
  if (status && !validStatuses.includes(status)) {
    return res.status(400).json({ message: 'Invalid status value' });
  }

  try {
    const isUpdated = await updateRestaurant(restaurantId, restaurantName, status);
    if (isUpdated) {
      res.json({ message: 'Restaurant updated successfully' });
    } else {
      res.status(404).json({ message: 'Restaurant not found or no changes made' });
    }
  } catch (error) {
    res.status(400).json({ message: 'Error updating restaurant', error: error.message });
  }
});

// ✅ Add a new restaurant (default status is "Pending")
app.post('/restaurants', async (req, res) => {
  const { restaurantName, status = 'Pending' } = req.body;

  if (!restaurantName) {
    return res.status(400).json({ message: 'Restaurant name is required' });
  }

  try {
    const restaurantId = await addRestaurant(restaurantName, status);
    res.status(201).json({
      message: 'Restaurant added successfully',
      restaurantId,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error adding restaurant', error: error.message });
  }
});

// ✅ Get only the email of a user by restaurant userId
app.get('/restaurants/user/:userId/email', async (req, res) => {
  try {
    const email = await getUserByRestaurantId(req.params.userId);
    if (email) {
      res.json({ email });
    } else {
      res.status(404).json({ message: 'Email not found for this restaurant user' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error fetching email', error: error.message });
  }
});

// ✅ Get reservations by restaurantId
app.get('/reservations/:restaurantId', async (req, res) => {
  try {
    const reservations = await getReservationsByRestaurantId(req.params.restaurantId);
    if (reservations.length > 0) {
      res.json(reservations);
    } else {
      res.status(404).json({ message: 'No reservations found for this restaurant' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error fetching reservations', error: error.message });
  }
});

// New endpoint to get all reservations
app.get('/reservations', async (req, res) => {
  try {
    const reservations = await getAllReservations();
    res.json(reservations);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch reservations' });
  }
});

// Get deals by restaurantId
app.get('/deals/:restaurant_id', async (req, res) => {
  const restaurant_id = req.params.restaurant_id;
  try {
    const deals = await getDealsByRestaurantId(restaurant_id);
    if (deals.length > 0) {
      res.json(deals);
    } else {
      res.status(404).json({ message: 'No deals found for this restaurant' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error fetching deals', error: error.message });
  }
});

// ✅ Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

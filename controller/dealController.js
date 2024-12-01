const Deal = require("../model/Deal");

// Add a new deal
const addDeal = async (req, res) => {
    try {
      const { name, category, price, details } = req.body;
      const image = req.file ? req.file.path : null; // Get the uploaded image path
  
      const newDeal = new Deal({ name, category, price, details, image });
      await newDeal.save();
  
      res.status(201).json({ message: "Deal added successfully", deal: newDeal });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  

// Get all deals
const getDeals = async (req, res) => {
  try {
    const deals = await Deal.find();
    res.status(200).json(deals);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Delete a deal
const deleteDeal = async (req, res) => {
  try {
    const { id } = req.params;
    await Deal.findByIdAndDelete(id);
    res.status(200).json({ message: "Deal deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Update a deal
const updateDeal = async (req, res) => {
    try {
      const { id } = req.params;
      const { name, category, price, details } = req.body;
      const image = req.file ? req.file.path : undefined; // Update image only if provided
  
      const updatedDeal = await Deal.findByIdAndUpdate(
        id,
        { name, category, price, details, ...(image && { image }) },
        { new: true }
      );
  
      res.status(200).json({ message: "Deal updated successfully", deal: updatedDeal });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  

module.exports = { addDeal, getDeals, deleteDeal, updateDeal };

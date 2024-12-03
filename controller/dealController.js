const Deal = require("../model/Deal")
const uploadOnCloudinary = require("../utils/cloudinary")

const addDeal = async (req, res) => {
  try {
    const { name, category, price, details } = req.body
    let imageUrl = null

    if (req.file) {
      const uploadResult = await uploadOnCloudinary(req.file.path)
      imageUrl = uploadResult.secure_url
    }

    const newDeal = new Deal({
      name,
      category,
      price,
      details,
      image: imageUrl,
    })
    await newDeal.save()

    res.status(201).json({ message: "Deal added successfully", deal: newDeal })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}
const getDeals = async (req, res) => {
  try {
    const deals = await Deal.find()
    res.status(200).json(deals)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

const deleteDeal = async (req, res) => {
  try {
    const { id } = req.params
    await Deal.findByIdAndDelete(id)
    res.status(200).json({ message: "Deal deleted successfully" })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

const updateDeal = async (req, res) => {
  try {
    const { id } = req.params
    const { name, category, price, details } = req.body
    let imageUrl = undefined

    if (req.file) {
      const uploadResult = await uploadOnCloudinary(req.file.path) // Upload to Cloudinary
      imageUrl = uploadResult.secure_url // Extract the secure URL
    }

    const updatedDeal = await Deal.findByIdAndUpdate(
      id,
      { name, category, price, details, ...(imageUrl && { image: imageUrl }) },
      { new: true }
    )

    res
      .status(200)
      .json({ message: "Deal updated successfully", deal: updatedDeal })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}
module.exports = { addDeal, getDeals, deleteDeal, updateDeal }

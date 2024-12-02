require("dotenv").config();
const { v2: cloudinary } = require('cloudinary');
const fs = require('fs');

cloudinary.config({ 
    cloud_name: process.env.CLOUD_NAME,
    api_key: process.env.API_KEY,
    api_secret: process.env.API_SECRET, 
});

const uploadOnCloudinary = async (path) => {
    try {
        if (!path) return null;
        const response = await cloudinary.uploader.upload(path, {
            resource_type: 'auto' 
        });

        console.log(`File uploaded on Cloudinary: ${response.url}`);
        return response;
    } catch (error) {
        console.error('Error uploading to Cloudinary:', error); 
        return null;
    }
};

module.exports = uploadOnCloudinary;
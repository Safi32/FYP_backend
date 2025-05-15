import 'package:dine/widgets/sidebar_menu.dart';
import 'package:dine/widgets/top_navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UnRestaurantDetailScreen extends StatefulWidget {
  final dynamic restaurant;

  UnRestaurantDetailScreen({required this.restaurant});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<UnRestaurantDetailScreen> {
  bool showReviews = false; // Toggle for Reviews Tab
  bool isHoveringRemove = false; // Hover state for Remove button
  bool isHoveringReview = false; // Hover state for Review button
  bool isRemoved = false; // State to track if the restaurant is removed

  Future<void> _removeRestaurant() async {
    final restaurantId = widget.restaurant['id']; // Assuming 'id' is the restaurant's unique identifier

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/restaurants/$restaurantId'),
      );

      if (response.statusCode == 200) {
        // Restaurant deleted successfully
        setState(() {
          isRemoved = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant registration removed successfully')),
        );

        // Navigate back to the previous screen
        Navigator.pop(context);
      } else if (response.statusCode == 404) {
        // Restaurant not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant not found')),
        );
      } else {
        // Other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting restaurant')),
        );
      }
    } catch (error) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    if (isRemoved) {
      // If the restaurant is removed, show a message or navigate back
      return Scaffold(
        body: Center(
          child: Text('Restaurant registration has been removed.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Sidebar
          SidebarMenu(activeItem: 'Restaurants'),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navbar
                TopNavbar(avatarPath: 'assets/admin_avatar.png'),

                // Add margin below Top Navbar
                SizedBox(height: 10),

                // Header Section with Back Arrow
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 201, 74, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (showReviews) {
                            setState(() {
                              showReviews = false;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant['restaurantName'] ?? 'N/A',
                                  style: TextStyle(
                                    height: 4,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Registration date: ${restaurant['createdAt'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.white,height: -2),
                                ),
                              ],
                            ),
                           
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content with Scroll
                Expanded(
                  child: showReviews
                      ? _buildReviewsTab()
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Section: Restaurant Information
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Restaurant Information
                                    _sectionTitle("Restaurant Information"),
                                    _infoRow("Restaurant-Name", restaurant['restaurantName'] ?? 'N/A'),
                                    _infoRow("Email", restaurant['email'] ?? 'N/A'),
                                    _infoRow("Admin", restaurant['username'] ?? 'N/A'),
                                    SizedBox(height: 20),

                                    // Restaurant Address
                                    _sectionTitle("Restaurant Address"),
                                    _infoRow("Address", restaurant['restaurantAddress'] ?? 'N/A'),
                                    SizedBox(height: 20),

                                    // Social Media
                                    _sectionTitle("Social Media"),
                                    _infoRow("Website", restaurant['websiteUrl'] ?? 'N/A'),
                                    _infoRow("Social Media Links", restaurant['socialMediaLinks'] ?? 'N/A'),
                                    SizedBox(height: 20),

                                    // Restaurant Type
                                    _sectionTitle("Restaurant Type"),
                                    _infoRow("Type", restaurant['restaurantType'] ?? 'N/A'),
                                    SizedBox(height: 20),

                                    // Operational Details
                                    _sectionTitle("Operational Details"),
                                    _infoRow("Opening Time", restaurant['operationalHours'] ?? 'N/A'),
                                    _infoRow("Minimum Price", restaurant['minPriceRange']?.toString() ?? 'N/A'),
                                    _infoRow("Maximum Price", restaurant['maxPriceRange']?.toString() ?? 'N/A'),
                                    SizedBox(height: 20),

                                    // Reservation Policy
                                    _sectionTitle("Reservation Policy"),
                                    _infoRow("Accept Reservation", restaurant['acceptReservation'] ?? 'N/A'),
                                    _infoRow("Minimum Days", restaurant['restaurantMinDays']?.toString() ?? 'N/A'),
                                    _infoRow("Minimum Hours", restaurant['restaurantMinHours']?.toString() ?? 'N/A'),
                                    SizedBox(height: 20),

                                    // Additional Features
                                    _sectionTitle("Restaurant Additional Features"),
                                    _infoRow("Features", restaurant['restaurantFeatures'] ?? 'N/A'),
                                    SizedBox(height: 20),

                                    // Additional Notes
                                    _sectionTitle("Additional Notes"),
                                    _infoRow("Notes", restaurant['additionalNotes'] ?? 'N/A'),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),

                              SizedBox(width: 20),

                              // Right Section: Restaurant Images
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle("Restaurant Images"),
                                    SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        restaurant['image'] ?? 'https://via.placeholder.com/150',
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/restaurant1.webp', // Local fallback image
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              restaurant['image'] ?? 'https://via.placeholder.com/150',
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/food3.jpg', // Local fallback image
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              restaurant['image'] ?? 'https://via.placeholder.com/150',
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/food2.jpg', // Local fallback image
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        restaurant['image'] ?? 'https://via.placeholder.com/150',
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/food1.jpg', // Local fallback image
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 201, 74, 1),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Reviews ${widget.restaurant['reviewCount'] ?? 'N/A'}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildReviewItem("Ali", "Great experience!", false),
          _buildReviewItem("Kamran shah", "Amazing service!", true, "Thanks!"),
          _buildReviewItem("Ali", "Highly recommend!", false),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String review, bool hasReply,
      [String? reply]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            review,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          if (hasReply) ...[
            SizedBox(height: 10),
            Text(
              "Reply",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 5),
            Text(
              reply!,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }
}
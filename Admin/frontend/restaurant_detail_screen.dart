import 'package:dine/widgets/sidebar_menu.dart';
import 'package:dine/widgets/top_navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final dynamic restaurant;

  RestaurantDetailScreen({required this.restaurant});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isHoveringRemove = false;
  bool isRemoved = false;
  List<dynamic> reservations = [];
  bool isLoadingReservations = true;
  List<dynamic> deals = [];
  bool isLoadingDeals = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchReservations(widget.restaurant['id']);
    fetchDeals(widget.restaurant['id']); // Fetch deals with restaurantId
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchDeals(int restaurant_id) async {
    setState(() {
      isLoadingDeals = true;
    });

    final response = await http.get(Uri.parse('http://localhost:3000/deals/$restaurant_id'));

    if (response.statusCode == 200) {
      setState(() {
        deals = jsonDecode(response.body);
        isLoadingDeals = false;
      });
    } else {
      setState(() {
        isLoadingDeals = false;
      });
      print('Failed to load deals');
    }
  }

  Future<void> _removeRestaurant() async {
    final restaurantId = widget.restaurant['id'];

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/restaurants/$restaurantId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          isRemoved = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant registration removed successfully')),
        );

        Navigator.pop(context);
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant not found')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting restaurant')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: ${error.toString()}')),
      );
    }
  }

  Future<void> fetchReservations(int restaurantId) async {
    setState(() {
      isLoadingReservations = true;
    });

    final response = await http.get(Uri.parse('http://localhost:3000/reservations/$restaurantId'));

    if (response.statusCode == 200) {
      setState(() {
        reservations = jsonDecode(response.body);
        isLoadingReservations = false;
      });
    } else {
      setState(() {
        isLoadingReservations = false;
      });
      print('Failed to load reservations');
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    if (isRemoved) {
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
          SidebarMenu(activeItem: 'Restaurants'),
          Expanded(
            child: Column(
              children: [
                TopNavbar(avatarPath: 'assets/admin_avatar.png'),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(20),
                  height: 150,
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
                          Navigator.pop(context);
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
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Registration date: ${restaurant['createdAt'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.white, height: -2),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow, size: 20),
                                SizedBox(width: 5),
                                Text(
                                  "${restaurant['rating'] ?? 'N/A'} | ${restaurant['reviewCount'] ?? 'N/A'} Reviews",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Container to limit the width of the TabBar
                      Container(
                        width: 720, // Set the width to 500 pixels
                        child: TabBar(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          controller: _tabController,
                          indicatorColor: const Color.fromARGB(255, 201, 74, 1),
                          labelColor: const Color.fromARGB(255, 201, 74, 1),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Restaurant Information'),
                            Tab(text: 'Deals'),
                            Tab(text: 'Reservations'),
                            Tab(text: 'Reviews'),
                          ],
                        ),
                      ),
                      // You can add other widgets here if needed
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle("Restaurant Information"),
                                  _infoRow("Restaurant-Name", restaurant['restaurantName'] ?? 'N/A'),
                                  _infoRow("Email", restaurant['email'] ?? 'N/A'),
                                  _infoRow("Admin", restaurant['username'] ?? 'N/A'),
                                  SizedBox(height: 20),
                                  _sectionTitle("Restaurant Address"),
                                  _infoRow("Address", restaurant['restaurantAddress'] ?? 'N/A'),
                                  SizedBox(height: 20),
                                  _sectionTitle("Social Media"),
                                  _infoRow("Website", restaurant['websiteUrl'] ?? 'N/A'),
                                  _infoRow("Social Media Links", restaurant['socialMediaLinks']?.toString() ?? 'N/A'),
                                  SizedBox(height: 20),
                                  _sectionTitle("Restaurant Type"),
                                  _infoRow("Type", restaurant['restaurantType'] ?? 'N/A'),
                                  SizedBox(height: 20),
                                  _sectionTitle("Operational Details"),
                                  _infoRow("Opening Time", restaurant['operationalHours'] ?? 'N/A'),
                                  _infoRow("Minimum Price", restaurant['minPriceRange']?.toString() ?? 'N/A'),
                                  _infoRow("Maximum Price", restaurant['maxPriceRange']?.toString() ?? 'N/A'),
                                  SizedBox(height: 20),
                                  _sectionTitle("Reservation Policy"),
                                  _infoRow("Accept Reservation", restaurant['acceptReservation'] ?? 'N/A'),
                                  _infoRow("Minimum Days", restaurant['restaurantMinDays']?.toString() ?? 'N/A'),
                                  _infoRow("Minimum Hours", restaurant['restaurantMinHours']?.toString() ?? 'N/A'),
                                  SizedBox(height: 20),
                                  _sectionTitle("Restaurant Additional Features"),
                                  _infoRow("Features", restaurant['restaurantFeatures'] ?? 'N/A'),
                                  SizedBox(height: 20),
                                  _sectionTitle("Additional Notes"),
                                  _infoRow("Notes", restaurant['additionalNotes'] ?? 'N/A'),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
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
                                          'assets/restaurant1.webp',
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
                                                'assets/food3.jpg',
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
                                                'assets/food2.jpg',
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
                                          'assets/food1.jpg',
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
                      _buildDealsTab(),
                      _buildReservationsTab(),
                      _buildReviewsTab(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onHover: (hovering) {
                          setState(() {
                            isHoveringRemove = hovering;
                          });
                        },
                        onTap: () async {
                          // Show confirmation dialog
                          bool? confirmRemove = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirm Removal"),
                                content: Text("Are you sure you want to remove the registration?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true), // Confirm removal
                                    child: Text("Yes"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 201, 74, 1), // White text
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false), // Cancel removal
                                    child: Text("No"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 201, 74, 1), // White text
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          // If the user confirmed the removal, call the _removeRestaurant method
                          if (confirmRemove == true) {
                            _removeRestaurant();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isHoveringRemove
                                ? Colors.white
                                : const Color.fromARGB(255, 201, 74, 1),
                            border: Border.all(
                              color: const Color.fromARGB(255, 201, 74, 1),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          child: Text(
                            "Remove Registration",
                            style: TextStyle(
                              fontSize: 16,
                              color: isHoveringRemove
                                  ? const Color.fromARGB(255, 201, 74, 1)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildDealsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Deals Offering (${deals.length})",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 201, 74, 1),
            ),
          ),
          SizedBox(height: 20),
          if (isLoadingDeals)
            CircularProgressIndicator()
          else if (deals.isEmpty)
            Text('No deals available.')
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: deals.map((deal) {
                    return _buildDealItem(
                      deal['deal_name'] ?? 'N/A',
                      deal['deal_details'] ?? 'N/A',
                      'Pkr ${deal['deal_price'] ?? 'N/A'}',
                      deal['image'] ?? 'N/A',
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDealItem(String name, String description, String price, String imagePath) {
    return SizedBox(
      width: 400,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image on the left side
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imagePath,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/food1.jpg', // Replace with your placeholder image
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            // Spacer to push the price to the right
            SizedBox(width: 20), // Optional spacing
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 201, 74, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reservations",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 201, 74, 1),
            ),
          ),
          SizedBox(height: 20),
          isLoadingReservations
              ? Center(child: CircularProgressIndicator())
              : reservations.isEmpty
                  ? Center(child: Text('No reservations found'))
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: reservations.map((reservation) {
                            // Extract the date part from the reservationDate string
                            String reservationDate = reservation['reservationDate'] != null
                                ? reservation['reservationDate'].split('T')[0]
                                : 'N/A';

                            // Use the reservationTime as a simple string
                            String reservationTime = reservation['reservationTime'] ?? 'N/A';

                            // Use the username instead of userId
                            String userName = reservation['userName'] ?? 'N/A'; // Fetch the userName field

                            return _buildReservationItem(
                              "User Name: " + userName,  // Use the username here
                              "Number of Persons: " + (reservation['numberOfPersons']?.toString() ?? 'N/A'),
                              "Reservation Day: " + reservationDate,
                              "Reservation Time: " + reservationTime,  // Use the reservationTime here
                              "Table Number: " + (reservation['tableNumber']?.toString() ?? 'N/A'),
                              "Status: " + (reservation['reservationStatus'] ?? 'N/A'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildReservationItem(String name, String deal, String date, String time, String table, String price) {
    return Align(
      alignment: Alignment.centerLeft, // Aligns the box to the left
      child: SizedBox(
        width: 500, // Fixed width
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          padding: EdgeInsets.all(20.0),  // Increased padding for more height
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/user_avatar.png'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,  // This will now display the user name
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          deal,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),  // Added some space between the rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Reservation Day
                  Text(
                    date,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 5), // Added some space before time field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Reservation Time
                  Text(
                    time,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    table,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 201, 74, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                color: const Color.fromARGB(255, 201, 74, 1),
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

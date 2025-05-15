import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dine/screens/restaurant_detail_screen.dart';


class TopNavbar extends StatefulWidget {
  final String avatarPath;

  TopNavbar({required this.avatarPath});

  @override
  _TopNavbarState createState() => _TopNavbarState();
}

class _TopNavbarState extends State<TopNavbar> {
  String _selectedOption = 'User'; // Default selection
  bool _isAdminDropdownOpen = false; // Track if the dropdown is open
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry; // Overlay entry for the dropdown

  // Search for users
  void _searchUsers(BuildContext context, String username) async {
    final url = Uri.parse('http://localhost:3000/users/search/$username'); // Replace with your API URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(users: users, isUserSearch: true),
        ),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users')),
      );
    }
  }

  // Search for restaurants
void _searchRestaurants(BuildContext context, String restaurantName) async {
  final url = Uri.parse('http://localhost:3000/restaurants/search/$restaurantName');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> allRestaurants = json.decode(response.body);
    
    // Filter only restaurants with status "Accepted"
    final List<dynamic> acceptedRestaurants = allRestaurants
        .where((restaurant) => restaurant['status'] == 'Accepted')
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(restaurants: acceptedRestaurants, isUserSearch: false),
      ),
    );
  } else {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load restaurants')),
    );
  }
}


  // Show the dropdown overlay
  void _showDropdown(BuildContext context) {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  final Offset offset = renderBox.localToGlobal(Offset.zero);

  // Get the size of the dropdown
  const double dropdownWidth = 250;
  const double dropdownHeight = 200; // Adjust based on your dropdown content

  // Get the size of the viewport
  final double viewportWidth = MediaQuery.of(context).size.width;
  final double viewportHeight = MediaQuery.of(context).size.height;

  // Calculate the available space below the admin section
  final double spaceBelow = viewportHeight - (offset.dy + renderBox.size.height);
  final double spaceAbove = offset.dy;

  // Adjust the position of the dropdown to stay within the viewport
  double top;
  if (spaceBelow >= dropdownHeight) {
    // If there's enough space below, show the dropdown below the admin section
    top = offset.dy + renderBox.size.height;
  } else if (spaceAbove >= dropdownHeight) {
    // If there's not enough space below but enough space above, show the dropdown above the admin section
    top = offset.dy - dropdownHeight;
  } else {
    // If there's not enough space above or below, show the dropdown at the bottom of the viewport
    top = viewportHeight - dropdownHeight;
  }

  // Ensure the dropdown stays within the horizontal bounds of the viewport
  double left = offset.dx;
  if (left + dropdownWidth > viewportWidth) {
    left = viewportWidth - dropdownWidth;
  }
  if (left < 0) {
    left = 0;
  }

  _overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: dropdownWidth,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Profile
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(widget.avatarPath),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ismail", // Admin name
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Ismail@gmail.com", // Admin email
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Address
              Text(
                "Address:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "123 Main St, Pakistan", // Admin address
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // Insert the overlay into the Overlay
  Overlay.of(context)?.insert(_overlayEntry!);
}
  // Hide the dropdown overlay
  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideDropdown(); // Clean up the overlay when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2), // Shadow below the top bar, no left shadow
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Bar with Dropdown
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.5)), // Light border
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Dropdown for User/Restaurant selection
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Light background color
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      border: Border.all(color: Colors.grey.withOpacity(0.3)), // Light border
                    ),
                    child: DropdownButton<String>(
                      value: _selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue!;
                        });
                      },
                      items: <String>['User', 'Restaurant']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(
                                value == 'User' ? Icons.person : Icons.restaurant,
                                color: Colors.orange[700], // Icon color
                                size: 18,
                              ),
                              SizedBox(width: 8), // Space between icon and text
                              Text(
                                value,
                                style: TextStyle(
                                  color: Colors.grey[800], // Text color
                                  fontWeight: FontWeight.w500, // Medium font weight
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      underline: Container(), // Remove the default underline
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[700], // Icon color
                      ),
                      elevation: 2, // Add a slight elevation
                      borderRadius: BorderRadius.circular(8), // Rounded corners for dropdown menu
                      dropdownColor: Colors.grey[100], // Background color of dropdown menu
                    ),
                  ),
                  SizedBox(width: 10),

                  // Search TextField
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search by ${_selectedOption.toLowerCase()}",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          if (_selectedOption == 'User') {
                            _searchUsers(context, value);
                          } else {
                            _searchRestaurants(context, value);
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.search, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20),

          // Admin Info with Dropdown
          Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _isAdminDropdownOpen = !_isAdminDropdownOpen; // Toggle dropdown visibility
                  });
                  if (_isAdminDropdownOpen) {
                    _showDropdown(context); // Show dropdown
                  } else {
                    _hideDropdown(); // Hide dropdown
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 121, 97, 97).withOpacity(0.5)), // Light border
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(widget.avatarPath), // Profile picture
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Admin",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        _isAdminDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchResultsPage extends StatefulWidget {
  final List<dynamic> users;
  final List<dynamic> restaurants;
  final bool isUserSearch;

  SearchResultsPage({this.users = const [], this.restaurants = const [], required this.isUserSearch});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  int? _hoveredIndex;

  // Function to delete a user or restaurant from the database
  Future<void> _deleteItem(int id) async {
    final url = Uri.parse(widget.isUserSearch
        ? 'http://localhost:3000/users/$id'
        : 'http://localhost:3000/restaurants/$id'); // Replace with your API URL
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // If the item is successfully deleted, update the UI
      setState(() {
        if (widget.isUserSearch) {
          widget.users.removeWhere((item) => item['id'] == id);
        } else {
          widget.restaurants.removeWhere((item) => item['id'] == id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.isUserSearch ? 'User' : 'Restaurant'} deleted successfully')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete ${widget.isUserSearch ? 'user' : 'restaurant'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.isUserSearch ? widget.users : widget.restaurants;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC94A01), Color(0xFFE67E22)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Navigate to the restaurant's "More Info" page
                          if (!widget.isUserSearch) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailScreen(restaurant: item),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(0xFFC94A01),
                                child: Text(
                                  '${item['id']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.isUserSearch
                                          ? (item['username']?.toString() ?? 'Unknown User')
                                          : (item['restaurantName']?.toString() ?? 'Unknown Restaurant'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    if (widget.isUserSearch)
                                      Text(
                                        item['email'] ?? 'No Email',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Show delete icon only when hovered
                              if (_hoveredIndex == index)
  IconButton(
    icon: Icon(
      Icons.delete,
      color: Colors.red,
    ),
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this item?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 201, 74, 1),
                ),
                child: Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _deleteItem(item['id']); // Delete the item
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 201, 74, 1),
                ),
                child: Text(
                  'Yes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  ),

                              // Show arrow icon when not hovered
                              if (_hoveredIndex != index)
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
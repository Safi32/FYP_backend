import 'package:dine/screens/Unregistered_details.dart';
import 'package:dine/screens/restaurant_detail_screen.dart';
import 'package:dine/widgets/sidebar_menu.dart';
import 'package:dine/widgets/top_navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'report_generator.dart'; // Import the report generator file

class RestaurantScreen extends StatefulWidget {
  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  bool isHoveringSendEmail = false;
  bool showRegistered = false; // Toggle state
  bool showAllRestaurants = false; // State to manage show more

  late Future<List<dynamic>> _registeredRestaurants;
  late Future<List<dynamic>> _pendingRestaurants;
  late Future<List<dynamic>> _dealCategories;

  @override
  void initState() {
    super.initState();
    _registeredRestaurants = fetchRestaurants(status: 'Accepted');
    _pendingRestaurants = fetchRestaurants(status: 'Pending');
    _dealCategories = fetchDealCategories();
  }

  Future<List<dynamic>> fetchRestaurants({String? status}) async {
    final url = Uri.parse('http://localhost:3000/restaurants${status != null ? '?status=$status' : ''}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<void> updateRestaurantStatus(String restaurantId, String status) async {
    final url = Uri.parse('http://localhost:3000/restaurants/$restaurantId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _registeredRestaurants = fetchRestaurants(status: 'Accepted');
        _pendingRestaurants = fetchRestaurants(status: 'Pending');
      });
    } else {
      throw Exception('Failed to update restaurant status');
    }
  }

  Future<List<dynamic>> fetchDealCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/deal-categories'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load deal categories');
    }
  }

  Future<void> addDealCategory(String categoryName, PlatformFile? file) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost:3000/deal-categories'));
    request.fields['category_name'] = categoryName;

    if (file != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        file.bytes!,
        filename: file.name,
      ));
    }

    var response = await request.send();
    if (response.statusCode == 201) {
      print('Category added successfully');
    } else {
      print('Failed to add category');
    }
  }

  Future<void> updateDealCategory(String id, String categoryName, PlatformFile? file) async {
    var request = http.MultipartRequest('PUT', Uri.parse('http://localhost:3000/deal-categories/$id'));
    request.fields['category_name'] = categoryName;

    if (file != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        file.bytes!,
        filename: file.name,
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Category updated successfully');
    } else {
      print('Failed to update category');
    }
  }

  Future<void> deleteDealCategory(String id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/deal-categories/$id'));
    if (response.statusCode == 200) {
      print('Category deleted successfully');
    } else {
      print('Failed to delete category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(activeItem: 'Restaurants'),
          Expanded(
            child: Column(
              children: [
                TopNavbar(avatarPath: 'assets/admin_avatar.png'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _TabButton(
                              label: 'Registered Restaurant',
                              isActive: !showRegistered,
                              onTap: () {
                                setState(() {
                                  showRegistered = false;
                                });
                              },
                            ),
                            SizedBox(width: 10),
                            _TabButton(
                              label: 'Restaurant Request',
                              isActive: showRegistered,
                              onTap: () {
                                setState(() {
                                  showRegistered = true;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        FutureBuilder<List<dynamic>>(
                          future: showRegistered ? _pendingRestaurants : _registeredRestaurants,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text("Loading...", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                            } else if (snapshot.hasData) {
                              return Text(
                                showRegistered
                                    ? "Restaurant Registration Request"
                                    : "Registered Restaurant (${snapshot.data!.length})",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              );
                            } else {
                              return Text("No restaurants found", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        showRegistered
                            ? _buildRestaurantRequestTable()
                            : FutureBuilder<List<dynamic>>(
                                future: _registeredRestaurants,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text("Error: ${snapshot.error}"));
                                  } else if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        _buildRestaurantTable(snapshot.data!.take(showAllRestaurants ? snapshot.data!.length : 3).toList()),
                                        if (!showAllRestaurants && snapshot.data!.length > 3)
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                showAllRestaurants = true;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to orange
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0), // Set rounded corners
                                              ),
                                            ),
                                            child: Text(
                                              "Show More",
                                              style: TextStyle(color: Colors.white), // Set text color to white
                                            ),
                                          ),
                                        SizedBox(height: 20),
                                        _buildCategoriesTable(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _showAddCategoryDialog();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to orange
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0), // Set rounded corners
                                                ),
                                              ),
                                              child: Text(
                                                "+ Add Category",
                                                style: TextStyle(color: Colors.white), // Set text color to white
                                              ),
                                            ),
                                            SizedBox(width: 10), // Add some spacing between the buttons
                                            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportPage()),
    );
  },
  child: Text('Revenue Report'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to orange
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Set rounded corners
    ),
    foregroundColor: Colors.white, // Set text color to white
  ),
),

                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Center(child: Text("No restaurants found"));
                                  }
                                },
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
      backgroundColor: Colors.white,
    );
  }

  Widget _TabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isActive ? const Color.fromARGB(255, 201, 74, 1) : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            if (isActive)
              Container(
                height: 2,
                width: 150,
                color: const Color.fromARGB(255, 201, 74, 1),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantTable(List<dynamic> restaurants) {
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(width: 0.5, color: Colors.grey[300]!),
      ),
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(4),
        4: FlexColumnWidth(2),
        5: FlexColumnWidth(3),
        6: FlexColumnWidth(3),
      },
      children: [
        _buildRegisteredTableHeader(),
        ...restaurants.asMap().entries.map((entry) {
          int index = entry.key;
          dynamic restaurant = entry.value;
          return _buildRegisteredTableRow(
            index + 1,
            restaurant['restaurantName'] ?? 'N/A',
            restaurant['restaurantAddress'] ?? 'N/A',
            restaurant['operationalHours'] ?? 'N/A',
            restaurant['minPriceRange']?.toString() ?? 'N/A',
            restaurant['maxPriceRange']?.toString() ?? 'N/A',
            restaurant,
          );
        }).toList(),
      ],
    );
  }

  TableRow _buildRegisteredTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[200]),
      children: [
        _buildTableCell("S. No", isHeader: true),
        _buildTableCell("Restaurant Name", isHeader: true),
        _buildTableCell("Address", isHeader: true),
        _buildTableCell("Working Time", isHeader: true),
        _buildTableCell("Min-Price", isHeader: true),
        _buildTableCell("Max-Price", isHeader: true),
        _buildTableCell("View More Info", isHeader: true),
      ],
    );
  }

  TableRow _buildRegisteredTableRow(
      int id, String name, String number, String email, String rating, String city, dynamic restaurant) {
    return TableRow(
      children: [
        _buildTableCell(id.toString()),
        _buildTableCell(name),
        _buildTableCell(number),
        _buildTableCell(email),
        _buildTableCell(rating),
        _buildTableCell(city),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 55),
          child: GestureDetector(
            onTap: () {
              Get.to(() => RestaurantDetailScreen(restaurant: restaurant));
            },
            child: Text(
              "View More Info",
              style: TextStyle(
                color: Colors.orange,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantRequestTable() {
    return FutureBuilder<List<dynamic>>(
      future: _pendingRestaurants,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          return Table(
            border: TableBorder(
              horizontalInside: BorderSide(width: 0.5, color: Colors.grey[300]!),
            ),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              _buildRequestTableHeader(),
              ...snapshot.data!.asMap().entries.map((entry) {
                int index = entry.key;
                dynamic restaurant = entry.value;
                return _buildRequestTableRow(
                  index + 1,
                  restaurant['restaurantName'] ?? 'N/A',
                  restaurant['restaurantAddress'] ?? 'N/A',
                  restaurant['operationalHours'] ?? 'N/A',
                  restaurant,
                );
              }).toList(),
            ],
          );
        } else {
          return Center(child: Text("No pending restaurants found"));
        }
      },
    );
  }

  TableRow _buildRequestTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[200]),
      children: [
        _buildTableCell("S. No", isHeader: true),
        _buildTableCell("Restaurant Name", isHeader: true),
        _buildTableCell("Address", isHeader: true),
        _buildTableCell("Working Time", isHeader: true),
        _buildTableCell("View More Info", isHeader: true),
        _buildTableCell("Action Perform", isHeader: true),
      ],
    );
  }

  TableRow _buildRequestTableRow(int id, String name, String address, String hours, dynamic restaurant) {
    return TableRow(
      children: [
        _buildTableCell(id.toString()),
        _buildTableCell(name),
        _buildTableCell(address),
        _buildTableCell(hours),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 55),
          child: GestureDetector(
            onTap: () {
              Get.to(() => UnRestaurantDetailScreen(restaurant: restaurant));
            },
            child: Text(
              "View More Info",
              style: TextStyle(
                color: Colors.orange,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Sending Email Confirmation"),
                          content: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 15),
                              Text("Please wait..."),
                            ],
                          ),
                        );
                      },
                    );

                    await updateRestaurantStatus(
                      restaurant['id'].toString(),
                      'Accepted',
                    );

                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () async {
                    await updateRestaurantStatus(restaurant['id'].toString(), 'Declined');
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesTable() {
    return FutureBuilder<List<dynamic>>(
      future: _dealCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 700,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Table(
                        border: TableBorder(
                          horizontalInside: BorderSide(width: 0.5, color: Colors.grey[300]!),
                        ),
                        columnWidths: {
                          0: FlexColumnWidth(0.5),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(3),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            children: [
                              _buildTableCell("S. No", isHeader: true),
                              _buildTableCell("Image", isHeader: true),
                              _buildTableCell("Name", isHeader: true),
                              _buildTableCell("Action Perform", isHeader: true),
                            ],
                          ),
                          ...snapshot.data!.asMap().entries.map((entry) {
                            int index = entry.key;
                            dynamic category = entry.value;
                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: 0.5, color: Colors.grey[300]!),
                                ),
                              ),
                              children: [
                                _buildTableCell((index + 1).toString()),
                                Container(
                                  height: 60, // Increased height for better visibility
                                  width: 60,
                                  margin: EdgeInsets.symmetric(vertical: 10), // Add vertical spacing
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0), // Rounded borders
                                    border: Border.all(color: Colors.grey[300]!, width: 1.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0), // Rounded borders for the image
                                    child: category['image'] != null
                                        ? Image.network(
                                            category['image'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.broken_image, color: Colors.red);
                                            },
                                          )
                                        : Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                ),
                                _buildTableCell(category['category_name'] ?? 'N/A'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _showEditCategoryDialog(category);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(context, category['id'].toString());
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text("No categories found"));
        }
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to orange
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await deleteDealCategory(categoryId);
                if (mounted) {
                  setState(() {
                    _dealCategories = fetchDealCategories();
                  });
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to red
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8), // Increased vertical padding
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }

  void _showEditCategoryDialog(dynamic category) {
    TextEditingController _categoryNameController = TextEditingController(text: category['category_name']);
    final _formKey = GlobalKey<FormState>();
    PlatformFile? _selectedFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit category"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryNameController,
                  decoration: InputDecoration(labelText: "Category Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter category name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                    if (result != null) {
                      _selectedFile = result.files.first;
                      if (mounted) {
                        setState(() {}); // Update the UI to show the selected file name
                      }
                    }
                  },
                  child: Text("Select Image"),
                ),
                if (_selectedFile != null)
                  Text(_selectedFile!.name, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to orange
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Show loading dialog
                  _showSavingDialog(context);
                  await updateDealCategory(category['id'].toString(), _categoryNameController.text, _selectedFile);
                  if (mounted) {
                    setState(() {
                      _dealCategories = fetchDealCategories();
                    });
                  }
                  // Close the loading dialog
                  Navigator.of(context).pop();
                  // Close the edit category dialog
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to orange
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 15),
              Text("Adding..."),
            ],
          ),
        );
      },
    );
  }

  void _showSavingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 15),
              Text("Saving..."),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    TextEditingController _categoryNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    PlatformFile? _selectedFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add new category"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryNameController,
                  decoration: InputDecoration(labelText: "Category Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter category name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                    if (result != null) {
                      _selectedFile = result.files.first;
                      if (mounted) {
                        setState(() {}); // Update the UI to show the selected file name
                      }
                    }
                  },
                  child: Text("Select Image"),
                ),
                if (_selectedFile != null)
                  Text(_selectedFile!.name, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to orange
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Show loading dialog
                  _showLoadingDialog(context);
                  await addDealCategory(_categoryNameController.text, _selectedFile);
                  if (mounted) {
                    setState(() {
                      _dealCategories = fetchDealCategories();
                    });
                  }
                  // Close the loading dialog
                  Navigator.of(context).pop();
                  // Close the add category dialog
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Add",
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Set button color to orange
              ),
            ),
          ],
        );
      },
    );
  }
}

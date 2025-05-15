import 'package:dine/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/restaurant_screen.dart';
import '../screens/login_screen.dart';
import '../screens/user_screen.dart'; // Import User Screen

class SidebarMenu extends StatelessWidget {
  
  final String activeItem;

  SidebarMenu({required this.activeItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(2, 0), // Shadow on the right side
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and Title
          Text(
            "Dine Deal.",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 201, 74, 1),
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Admin Dashboard",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 30),

          // Menu Items
          _MenuItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            isActive: activeItem == 'Dashboard',
            onTap: () {
              // Navigate to Dashboard
              Get.offAll(() => DashboardScreen());
            },
          ),
          _MenuItem(
            icon: Icons.restaurant,
            label: "Restaurants",
            isActive: activeItem == 'Restaurants',
            onTap: () {
              // Navigate to Restaurants
              Get.offAll(() => RestaurantScreen());
            },
          ),
          _MenuItem(
            icon: Icons.person,
            label: "Users",
            isActive: activeItem == 'Users',
            onTap: () {
              // Navigate to Users
              Get.offAll(() => UserScreen());
            },
          ),
          _MenuItem(
            icon: Icons.logout,
            label: "Logout",
            isActive: activeItem == 'Logout',
            onTap: () {
              // Navigate to Login
              Get.offAll(() => LoginScreen());
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isActive ? Color.fromARGB(255, 201, 74, 1).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? const Color.fromARGB(255, 201, 74, 1) : Colors.black),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color.fromARGB(255, 201, 74, 1) : Colors.black,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int totalUsers = 0;
  int totalAcceptedRestaurants = 0;
  int totalDeclinedRestaurants = 0;
  int totalReservations = 0;
  double totalProfit = 0.0;
  List<dynamic> detailedReservations = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final now = DateTime.now();
      final firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);
      final lastDayOfCurrentMonth = DateTime(now.year, now.month + 1, 0);

      final users = await fetchUsers(firstDayOfCurrentMonth, lastDayOfCurrentMonth);
      final acceptedRestaurants = await fetchRestaurants(status: 'Accepted', startDate: firstDayOfCurrentMonth, endDate: lastDayOfCurrentMonth);
      final declinedRestaurants = await fetchRestaurants(status: 'Declined', startDate: firstDayOfCurrentMonth, endDate: lastDayOfCurrentMonth);
      final reservations = await fetchAllReservations(firstDayOfCurrentMonth, lastDayOfCurrentMonth);

      setState(() {
        totalUsers = users.length;
        totalAcceptedRestaurants = acceptedRestaurants.length;
        totalDeclinedRestaurants = declinedRestaurants.length;
        totalReservations = reservations.length;
        detailedReservations = reservations;
        totalProfit = totalReservations * 50.0;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<List<dynamic>> fetchUsers(DateTime startDate, DateTime endDate) async {
    final url = Uri.parse('http://localhost:3000/users?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<dynamic>> fetchRestaurants({String? status, required DateTime startDate, required DateTime endDate}) async {
    final url = Uri.parse('http://localhost:3000/restaurants?status=$status&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<List<dynamic>> fetchAllReservations(DateTime startDate, DateTime endDate) async {
    final url = Uri.parse('http://localhost:3000/reservations?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reservations');
    }
  }

Future<void> generatePdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Monthly Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Total Users Registered: $totalUsers'),
              pw.Text('Total Accepted Restaurants: $totalAcceptedRestaurants'),
              pw.Text('Total Declined Restaurants: $totalDeclinedRestaurants'),
              pw.Text('Total Reservations: $totalReservations'),
              pw.Text('Total Profit: ${totalProfit.toStringAsFixed(2)} rupees'),
              pw.SizedBox(height: 20),
              pw.Text('Detailed Reservations:', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
  context: context,
  data: <List<String>>[
    <String>['User', 'Restaurant', 'Reservation Date'],
    ...detailedReservations.map((reservation) => [
          (reservation['userName'] ?? 'Unknown').toString(), // Convert to string
          (reservation['restaurantId'] ?? 'Unknown').toString(), // Convert to string
          (reservation['reservationDate'] ?? 'Unknown').toString(), // Convert to string
        ]),
  ],
),

            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Report'),
      ),
      body: Center(
        child: ElevatedButton(
  onPressed: generatePdf,
  child: Text('Generate PDF Report'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 201, 74, 1), // Orange color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
    ),
    foregroundColor: Colors.white, // White text
  ),
),

      ),
    );
  }
}

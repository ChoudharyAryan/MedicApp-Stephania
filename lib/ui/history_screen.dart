import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medapp/db/read_medicins.dart';
import 'package:medapp/ui/models/history_block.dart';

class MedicInfo {
  final String name;
  final int dosage;
  final String recurrence;
  final int quantity;
  final String startDate;
  final String endDate;
  final List<String> times;

  MedicInfo({
    required this.name,
    required this.dosage,
    required this.recurrence,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.times,
  });

  factory MedicInfo.fromJson(Map<String, dynamic> json) {
    return MedicInfo(
      name: json['name'],
      dosage: json['dosage'],
      recurrence: json['recurrence'],
      quantity: json['quantity'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      times: List<String>.from(json['times']),
    );
  }

  @override
  String toString() {
    return jsonEncode({
      'name': name,
      'dosage': dosage,
      'recurrence': recurrence,
      'quantity': quantity,
      'startDate': startDate,
      'endDate': endDate,
      'times': times,
    });
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<MedicInfo> allHistory = [];
  List<MedicInfo> history = [];
  bool isLoading = true;
  TextEditingController search = TextEditingController();

  Future<void> fetchHistoryForYesterday() async {
    try {
      // Calculate yesterday's date
      final DateTime yesterday =
          DateTime.now().subtract(const Duration(days: 1));
      final int day = yesterday.day;
      final int month = yesterday.month;
      final int year = yesterday.year;

      // Fetch data for yesterday
      List<Map<String, Object?>> data =
          await readMedicinsforDate(day, month, year);

      // If data exists, update the allHistory and history lists
      if (data.isNotEmpty) {
        setState(() {
          allHistory = data
              .map((e) => MedicInfo.fromJson(jsonDecode(e['data'].toString())))
              .toList();
          history = List.from(allHistory); // Initialize filtered list
        });
      }
    } catch (e) {
      debugPrint("Error fetching history for yesterday: $e");
    } finally {
      // Stop loading spinner regardless of the outcome
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterHistory(String query) {
    setState(() {
      if (query.isEmpty) {
        // If search bar is empty, reset to the full list
        history = List.from(allHistory);
      } else {
        // Filter based on the query
        history = allHistory
            .where((item) =>
                item.name.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchHistoryForYesterday(); // Fetch history for yesterday on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "History",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: search,
                decoration: const InputDecoration(
                  hintText: "Search",
                  border: OutlineInputBorder(),
                ),
                onChanged: filterHistory, // Call filterHistory on text change
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (history.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      MedicInfo info = history[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: historyBlock(
                          context,
                          name: info.name,
                          quantity: info.quantity,
                          startDate: info.startDate,
                          endDate: info.endDate,
                          times: info.times,
                        ),
                      );
                    },
                  ),
                )
              else
                const Center(
                  child: Text(
                    "No history available",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

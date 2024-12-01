import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medapp/db/read_medicins.dart';
import 'package:medapp/ui/models/history_block.dart';

class MedicInfo {
  final String name;
  final int dosage;
  final String recurrence;
  final int quantity;
  final String startDate;
  final String endDate;
  bool? status;
  final List<String> times;

  MedicInfo({
    required this.name,
    required this.dosage,
    required this.recurrence,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.times,
    this.status,
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'recurrence': recurrence,
        'quantity': quantity,
        'startDate': startDate,
        'endDate': endDate,
        'times': times,
        'status': status,
      };

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MedicInfo &&
        other.name == name &&
        other.dosage == dosage &&
        other.recurrence == recurrence &&
        other.quantity == quantity &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        listEquals(other.times, times);
  }

  @override
  int get hashCode => Object.hash(
      name, dosage, recurrence, quantity, startDate, endDate, times);
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
  final TextEditingController search = TextEditingController();

  List<MedicInfo> generateDailyBlocks(MedicInfo medic) {
    final List<MedicInfo> dailyBlocks = [];
    DateTime startDate;
    DateTime endDate;

    try {
      final DateFormat dateFormat = DateFormat('d MMMM yyyy');
      startDate = dateFormat.parse(medic.startDate);
      endDate = dateFormat.parse(medic.endDate);
    } catch (e) {
      log("Error parsing dates: $e");
      return dailyBlocks;
    }

    DateTime currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      for (var time in medic.times) {
        // Create a unique block for each `time` and `date`
        final MedicInfo block = MedicInfo(
          name: medic.name,
          dosage: medic.dosage,
          recurrence: medic.recurrence,
          quantity: medic.quantity,
          startDate:
              currentDate.toIso8601String().substring(0, 10), // Specific date
          endDate: medic.endDate,
          times: [time], // Specific time
        );

        // Add only if this block doesn't already exist
        if (!dailyBlocks.any((b) =>
            b.name == block.name &&
            b.startDate == block.startDate &&
            b.times.first == block.times.first)) {
          dailyBlocks.add(block);
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dailyBlocks;
  }

  Future<void> fetchHistoryForLast30Days() async {
    try {
      final DateTime today = DateTime.now();
      final DateTime thirtyDaysAgo = today.subtract(const Duration(days: 30));

      List<MedicInfo> fetchedHistory = [];

      for (int i = 0; i <= 30; i++) {
        final DateTime currentDate = thirtyDaysAgo.add(Duration(days: i));

        List<Map<String, Object?>> data = await readMedicinsforDate(
          currentDate.day,
          currentDate.month,
          currentDate.year,
        );

        if (data.isNotEmpty) {
          fetchedHistory.addAll(
            data.map(
                (e) => MedicInfo.fromJson(jsonDecode(e['data'].toString()))),
          );
        }
      }

      setState(() {
        for (var medication in fetchedHistory) {
          List<MedicInfo> dailyBlocks = generateDailyBlocks(medication);

          for (var block in dailyBlocks) {
            // Add block to allHistory only if it doesn't already exist
            if (!allHistory.any((b) =>
                b.name == block.name &&
                b.startDate == block.startDate &&
                b.times.first == block.times.first)) {
              allHistory.add(block);
            }
          }
        }

        history = List.from(allHistory); // Update displayed list
      });
    } catch (e) {
      debugPrint("Error fetching history for last 30 days: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterHistory(String query) {
    setState(() {
      if (query.isEmpty) {
        history = List.from(allHistory); // Reset to all history
      } else {
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
    fetchHistoryForLast30Days(); // Fetch last 30 days of history on initialization
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
                onChanged: filterHistory,
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

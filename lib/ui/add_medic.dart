import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medapp/db/inserdb.dart';
import 'package:medapp/ui/functions.dart';
import 'package:medapp/ui/models/fields.dart';

class MedicInfo {
  final String name;
  final int dosage;
  final String recurrence;
  final int quantity;
  final String startDate;
  final String endDate;
  final List<String> times;
  final int start_m;
  final int start_d;
  final int start_y;
  final int end_m;
  final int end_d;
  final int end_y;

  const MedicInfo(
      {this.name = "",
      this.dosage = -1,
      this.recurrence = "Daily",
      this.quantity = -1,
      this.startDate = "",
      this.endDate = "",
      this.times = const [],
      this.start_m = -1,
      this.start_d = -1,
      this.start_y = -1,
      this.end_m = -1,
      this.end_d = -1,
      this.end_y = -1});

  MedicInfo fromString(String val) {
    Map data = jsonDecode(val);
    return MedicInfo(
      name: data["name"],
      dosage: data["dosage"],
      recurrence: data["recurrence"],
      quantity: data["quantity"],
      startDate: data["startDate"],
      endDate: data["endDate"],
      times: [for (var x in data["times"]) x.toString()],
    );
  }

  MedicInfo fromJson(Map data) {
    return MedicInfo(
      name: data["name"],
      dosage: data["dosage"],
      recurrence: data["recurrence"],
      quantity: data["quantity"],
      startDate: data["startDate"],
      endDate: data["endDate"],
      times: data["times"],
    );
  }

  @override
  String toString() {
    return jsonEncode({
      "name": name,
      "dosage": dosage,
      "recurrence": recurrence,
      "quantity": quantity,
      "startDate": startDate,
      "endDate": endDate,
      "times": times,
    });
  }

  bool isValid() {
    if (name.isEmpty ||
        recurrence.isEmpty ||
        startDate.isEmpty ||
        endDate.isEmpty ||
        times.isEmpty) {
      return false;
    }
    if (dosage < 0 || quantity < 0) {
      return false;
    }
    return true;
  }

  MedicInfo copyWith({
    String? name,
    int? dosage,
    String? recurrence,
    int? quantity,
    String? startDate,
    String? endDate,
    List<String>? times,
    int? start_m,
    int? start_d,
    int? start_y,
    int? end_m,
    int? end_d,
    int? end_y,
  }) {
    return MedicInfo(
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        recurrence: recurrence ?? this.recurrence,
        quantity: quantity ?? this.quantity,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        times: times ?? this.times,
        start_m: start_m ?? this.start_m,
        start_d: start_d ?? this.start_d,
        start_y: start_y ?? this.start_y,
        end_m: end_m ?? this.end_m,
        end_d: end_d ?? this.end_d,
        end_y: end_y ?? this.end_y);
  }
}

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  MedicInfo medicInfo = const MedicInfo(times: [""]);
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int totalTimes = 1;

  Future<void> _pickDate(BuildContext context,
      {bool isStartDate = true}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000), // Adjust as needed
      lastDate: DateTime(2100), // Adjust as needed
    );

    setState(() {
      if (isStartDate) {
        _startDate = pickedDate!;
        medicInfo = medicInfo.copyWith(
            start_d: pickedDate.day,
            start_y: pickedDate.year,
            start_m: pickedDate.month,
            startDate: DateFormat("d MMMM y").format(pickedDate));
      } else {
        _endDate = pickedDate!;
        medicInfo = medicInfo.copyWith(
            end_d: pickedDate.day,
            end_y: pickedDate.year,
            end_m: pickedDate.month,
            endDate: DateFormat("d MMMM y").format(pickedDate));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
              child: Text(
        "Add medication",
        style: headingStyle,
      ))),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  InputField(
                      title: "Medication Name",
                      hint: "e.g.",
                      onChange: (String val) {
                        setState(() {
                          medicInfo = medicInfo.copyWith(name: val);
                        });
                      }),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: InputField(
                        title: "Dosage",
                        hint: "e.g: 1",
                        onChange: (String val) {
                          setState(() {
                            medicInfo =
                                medicInfo.copyWith(dosage: int.parse(val));
                          });
                        },
                      )),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                          value: medicInfo.recurrence,
                          items:
                              ['Daily', 'Weekly', 'Monthly'].map((recurrence) {
                            return DropdownMenuItem(
                              value: recurrence,
                              child: Text(recurrence),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              medicInfo = medicInfo.copyWith(recurrence: value);
                            });
                          },
                          decoration: const InputDecoration(
                            filled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  InputField(
                      title: "Miligram",
                      hint: "4 m.g.",
                      onChange: (String value) {
                        setState(() {
                          medicInfo =
                              medicInfo.copyWith(quantity: int.parse(value));
                        });
                      }),
                  GestureDetector(
                      onTap: () => _pickDate(context, isStartDate: true),
                      child: InputField(
                          isStyleOnly: true,
                          hint: DateFormat("d MMMM y").format(_startDate),
                          title: "StartDate")),
                  GestureDetector(
                      onTap: () => _pickDate(context, isStartDate: false),
                      child: InputField(
                          isStyleOnly: true,
                          hint: DateFormat("d MMMM y").format(_endDate),
                          title: "EndDate")),
                  for (int i = 0; i < totalTimes; i++)
                    InputField(
                      title: "Time(s) for Medication",
                      hint: medicInfo.times[i],
                      onChange: (p0) {
                        setState(() {
                          List<String> times = List.of(medicInfo.times);
                          times[i] = p0;
                          medicInfo = medicInfo.copyWith(times: times);
                        });
                      },
                    ),
                  FilledButton(
                      onPressed: () {
                        setState(() {
                          totalTimes++;
                          medicInfo = medicInfo.copyWith(
                              times: List.of(medicInfo.times)..add(""));
                        });
                      },
                      child: const Text("Add Time"))
                ],
              ),
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: const ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll<Color>(Color(0xFFB4D84C)),
              ),
              onPressed: () => _validateData(),
              child: const Center(
                child: Text('Next'),
              ),
            ),
          )
        ],
      ),
    );
  }

  _validateData() async {
    if (medicInfo.isValid()) {
      try {
        await _addTaskToDb();
        Get.snackbar(
          "Success",
          "Medication added!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      } catch (e) {}
    } else {
      Get.snackbar(
        "Required",
        "All fields are required !",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
    }
  }

  _addTaskToDb() async {
    await insertMedicinsforDate(
        data: medicInfo.toString(),
        start_m: medicInfo.start_m,
        start_d: medicInfo.start_d,
        start_y: medicInfo.start_y,
        end_m: medicInfo.end_m,
        end_d: medicInfo.end_d,
        end_y: medicInfo.end_y,
        createdAt: DateFormat("d MMMM y").format(DateTime.now()).toString());
  }
}

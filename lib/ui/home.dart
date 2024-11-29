import 'dart:developer';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medapp/ui/add_medic.dart';

import '../db/inserdb.dart';
import '../db/read_medicins.dart';
import 'history_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0; // Tracks the selected page
  int date = 0;
  int year = 0;
  int month = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: currentPageIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Get.to(() => const AddMedicationPage());
              },
              label: const Text("+ Add Medication"),
            )
          : null, // Floating Action Button only on Home Page
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          // Page 0: Home Page
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _showTimeline(),
                _showTasks(
                  date,
                  year,
                  month,
                ),
              ],
            ),
          ),

          // Page 1: HistoryScreen Page
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color(0xFFB4D84C),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Badge(child: Icon(Icons.calendar_month_outlined)),
            label: 'History',
          ),
        ],
      ),
    );
  }

  _showTimeline() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      child: EasyDateTimeLine(
        initialDate: DateTime.now(),
        onDateChange: (selectedDate) {
          //`selectedDate` the new date selected.
          setState(() {
            date = selectedDate.day;
            year = selectedDate.year;
            month = selectedDate.month;
          });
        },
        headerProps: const EasyHeaderProps(
          monthPickerType: MonthPickerType.switcher,
          dateFormatter: DateFormatter.fullDateDMY(),
        ),
        dayProps: const EasyDayProps(
          dayStructure: DayStructure.dayStrDayNum,
        ),
      ),
    );
  }

  _showTasks(
    int date,
    int year,
    int month,
  ) {
    return Expanded(
      child: FutureBuilder(
        future: readMedicinsforDate(date, month, year),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data?.isEmpty ?? true) {
              return const Center(
                child: Text("No medicine for today"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (_, index) {
                MedicInfo info = const MedicInfo()
                    .fromString(snapshot.data![index]["data"].toString());
                log(info.toString());
                return Dismissible(
                  key: Key(snapshot.data![index]["id"].toString()),
                  onDismissed: (direction) async {
                    // Remove the item from the data source.
                    await deleteTask(snapshot.data![index]["id"] as int? ?? 0);
                    setState(() {});
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(info.name),
                      subtitle: Text(
                          "${info.quantity} dose ${info.recurrence} from\n${info.startDate}"),
                      trailing: Text(info.endDate),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to load data ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

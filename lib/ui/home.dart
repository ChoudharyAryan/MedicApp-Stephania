import 'dart:math';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medapp/ui/add_medic.dart';
import 'package:medapp/ui/models/task_controller.dart';
import '../db/inserdb.dart';
import '../db/read_medicins.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _taskController = Get.put(TaskController());

  int currentPageIndex = 0;
  int date = 0;
  int year = 0;
  int month = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Get.to(() => const AddMedicationPage());
            _taskController.getTasks();
          },
          label: const Text("+ Add Medication")),
      body: Container(
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
            icon: Badge(child: Icon(Icons.calendar_month)),
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
        ));
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
                    child: Text("No medicin for today"),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (_, index) {
                      MedicInfo info = const MedicInfo()
                          .fromString(snapshot.data![index]["data"].toString());
                      return Dismissible(
                        key: Key(snapshot.data![index]["id"].toString()),
                        onDismissed: (direction) async {
                          // Remove the item from the data source.
                          await deleteTask(
                              snapshot.data![index]["id"] as int ?? 0);
                          setState(() async {});
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
                    });
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("failed to load data ${snapshot.error}"));
              }
              return const CircularProgressIndicator();
            })
        // Obx
        ); // Expanded
  }
}

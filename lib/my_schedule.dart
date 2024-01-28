import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'my_medicines.dart';
import 'dart:convert';  

class MySchedulePage extends StatefulWidget {
  @override
  _MySchedulesPageState createState() => _MySchedulesPageState();
}
class SelectedMedicinesCard extends StatelessWidget {
  final List<Medicine> selectedMedicines;

  SelectedMedicinesCard({required this.selectedMedicines});

  @override
  Widget build(BuildContext context) {
  return Card(
    color: Colors.grey[200],
    child: ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      
      title: const Text(
        'Medicines you have to take on this day:',
        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue)

      ),
      subtitle: SizedBox(
        height: 200, 
        child: ListView.builder(
          itemCount: selectedMedicines.length,
          itemBuilder: (context, index) {
            Medicine medicine = selectedMedicines[index];

            return Card(
              color: Colors.grey[100],
              child: ListTile(
                title: Text(
                  '${'You have to take'} ${medicine.name.toLowerCase()} ${medicine.howOften.toString().split('.').last.toLowerCase()} ${'in this day, you can take it'} ${medicine.mealTime.toString().split('.').last.toLowerCase()}',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

}

class _MySchedulesPageState extends State<MySchedulePage> {
  
  List<Medicine> medicines = [];
  late Map<DateTime, List<Medicine>> events;
  DateTime selectedDate = DateTime.now(); 

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedules'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: _buildSelectedMedicinesCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime(2000),
      lastDay: DateTime(2101),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          selectedDate = selectedDay;
        });
      },
    );
  }



  Widget _buildSelectedMedicinesCard() {
    return SelectedMedicinesCard(selectedMedicines: _updateDisplayedMedicines(selectedDate));
  }

  List<Medicine> _updateDisplayedMedicines(DateTime selectedDay) {
    DateTime selectedDayMidnight = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    List<Medicine> selectedDayMedicines = events[selectedDayMidnight] ?? [];

    print('Selected Medicines for ${selectedDay.toLocal()}: $selectedDayMedicines');

    // Update the selected medicines
    return selectedDayMedicines;
  }

  void _loadMedicines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? medicineStrings = prefs.getStringList('medicinesKey');
    if (medicineStrings != null) {
      setState(() {
        medicines = medicineStrings
            .map((jsonString) => Medicine.fromJson(json.decode(jsonString)))
            .toList();
        events = _generateEvents(medicines);
      });
    }
  }

  Map<DateTime, List<Medicine>> _generateEvents(List<Medicine> medicines) {
    Map<DateTime, List<Medicine>> events = {};

    for (var medicine in medicines) {
      DateTime startDate = medicine.startDate;
      DateTime endDate = medicine.endDate;

      while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
        events[startDate] = events[startDate] ?? [];
        events[startDate]!.add(medicine);

        startDate = startDate.add(const Duration(days: 1));
      }
    }

    return events;
  }
}

//my_medicines.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_schedule.dart';

enum MedicineType {
  Pill,
  Injection,
  Liquid,
  Drop,
  Powder,
}

enum MedicineFrequency {
  Daily,
  EveryOtherDay,
  EveryThreeDays,
}

enum MedicineHowOften {
  Once,
  Twice,
  Thrice,
}

enum MealTime {
  BeforeMeal,
  AfterMeal,
  Anytime,
}

class Medicine {
  String name = '';
  MedicineType type = MedicineType.Pill;
  MedicineFrequency frequency = MedicineFrequency.Daily;
  MedicineHowOften howOften = MedicineHowOften.Once;
  MealTime mealTime = MealTime.Anytime;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int? index;
  bool taken = false;

  Medicine({
    required this.name,
    required this.type,
    required this.frequency,
    required this.howOften,
    required this.mealTime,
    required this.startDate,
    required this.endDate,
    this.index,
  });

  Map<String, dynamic> toJson() {
    DateTime zeroedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    DateTime zeroedEndDate = DateTime(endDate.year, endDate.month, endDate.day);

    return {
      'name': name,
      'type': type.index,
      'frequency': frequency.index,
      'howOften': howOften.index,
      'mealTime': mealTime.index,
      'startDate': DateFormat('yyyy-MM-dd').format(zeroedStartDate),
      'endDate': DateFormat('yyyy-MM-dd').format(zeroedEndDate),
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] ?? '',
      type: MedicineType.values[json['type']] ?? MedicineType.Pill,
      frequency: MedicineFrequency.values[json['frequency']] ??
          MedicineFrequency.Daily,
      howOften:
          MedicineHowOften.values[json['howOften']] ?? MedicineHowOften.Once,
      mealTime: MealTime.values[json['mealTime']] ?? MealTime.Anytime,
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class MyMedicinesPage extends StatefulWidget {
  @override
  _MyMedicinesPageState createState() => _MyMedicinesPageState();
}

class _MyMedicinesPageState extends State<MyMedicinesPage> {
  List<Medicine> medicines = [];
  late SharedPreferences prefs;

    void _navigateToSchedulePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MySchedulePage(),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _loadMedicines();
    

  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicines'),
      ),
      body: _buildMedicinesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMedicineDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMedicinesList() {
    return ListView.builder(
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
        child: Slidable(
          actionPane: const SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Card(
            color: Colors.grey[200],
            child: ListTile(
              onTap: () {
                _showMedicineDetails(medicines[index]);
              },
              title: Text(medicines[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Type: ${medicines[index].type.toString().split('.').last}'),
                  Text(
                      'Frequency: ${medicines[index].frequency.toString().split('.').last}'),
                  Text(
                      'How Often: ${medicines[index].howOften.toString().split('.').last}'),
                  Text(
                      'Meal Time: ${medicines[index].mealTime.toString().split('.').last}'),
                  Text('Start Date: ${medicines[index].startDate.toLocal()}'),
                  Text('End Date: ${medicines[index].endDate.toLocal()}'),
                ],
              ),
            ),
          ),
          secondaryActions: [
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                _deleteMedicine(index);
              },
            ),
          ],
        
        )
        );
      },
    );
  }

  void _showAddMedicineDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailsPage(
          onDetailsSubmitted: (newMedicine) {
            if (newMedicine != null) {
              if (newMedicine.index != null) {
                _updateMedicine(newMedicine);
              } else {
                _addMedicine(newMedicine);
              }
            }
          },
        ),
      ),
    );
  }

  void _addMedicine(Medicine newMedicine) {
    setState(() {
      newMedicine.index = medicines.length;
      medicines.add(newMedicine);
    });

    _saveMedicines();
  }
  

  void _updateMedicine(Medicine updatedMedicine) {
    setState(() {
      medicines[updatedMedicine.index!] = updatedMedicine;
    });

    _saveMedicines();
  }

  void _showMedicineDetails(Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Medicine Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${medicine.name}'),
              Text('Type: ${medicine.type.toString().split('.').last}'),
              Text(
                  'Frequency: ${medicine.frequency.toString().split('.').last}'),
              Text(
                  'How Often: ${medicine.howOften.toString().split('.').last}'),
              Text(
                  'Meal Time: ${medicine.mealTime.toString().split('.').last}'),
              Text('Start Date: ${medicine.startDate.toLocal()}'),
              Text('End Date: ${medicine.endDate.toLocal()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editMedicine(medicine);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _loadMedicines() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? medicineStrings = prefs.getStringList('medicinesKey');
    if (medicineStrings != null) {
      setState(() {
        medicines = medicineStrings
            .map((jsonString) => Medicine.fromJson(json.decode(jsonString)))
            .toList();
      });
    }
  }

  void _saveMedicines() {
    List<String> medicineStrings =
        medicines.map((medicine) => json.encode(medicine.toJson())).toList();
    prefs.setStringList('medicinesKey', medicineStrings);
  }

  void _deleteMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
    });

    _saveMedicines();
  }

  void _editMedicine(Medicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailsPage(
          onDetailsSubmitted: (updatedMedicine) {
            if (updatedMedicine != null) {
              _updateMedicine(updatedMedicine);
            }
          },
          initialMedicine: medicine,
        ),
      ),
    );
  }
}

class MedicineDetailsPage extends StatefulWidget {
  final Function(Medicine?) onDetailsSubmitted;
  final Medicine? initialMedicine;

  MedicineDetailsPage({required this.onDetailsSubmitted, this.initialMedicine});

  @override
  _MedicineDetailsPageState createState() => _MedicineDetailsPageState();
}

class _MedicineDetailsPageState extends State<MedicineDetailsPage> {
  late TextEditingController _nameController;
  late MedicineType _selectedType;
  late MedicineFrequency _selectedFrequency;
  late MedicineHowOften _selectedHowOften;
  late MealTime _selectedMealTime;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialMedicine?.name);
    _selectedType = widget.initialMedicine?.type ?? MedicineType.Pill;
    _selectedFrequency =
        widget.initialMedicine?.frequency ?? MedicineFrequency.Daily;
    _selectedHowOften =
        widget.initialMedicine?.howOften ?? MedicineHowOften.Once;
    _selectedMealTime = widget.initialMedicine?.mealTime ?? MealTime.Anytime;
    _selectedStartDate = widget.initialMedicine?.startDate ?? DateTime.now();
    _selectedEndDate = widget.initialMedicine?.endDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialMedicine != null
            ? 'Update Medicine'
            : 'Add Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              onChanged: (value) {
              
              },
              decoration: const InputDecoration(labelText: 'Medicine Name'),
            ),
            _buildDropdown<MedicineType>(
              value: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              items: MedicineType.values,
              labelText: 'Medicine Type',
            ),
            _buildDropdown<MedicineFrequency>(
              value: _selectedFrequency,
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value!;
                });
              },
              items: MedicineFrequency.values,
              labelText: 'Medicine Frequency',
            ),
            _buildDropdown<MedicineHowOften>(
              value: _selectedHowOften,
              onChanged: (value) {
                setState(() {
                  _selectedHowOften = value!;
                });
              },
              items: MedicineHowOften.values,
              labelText: 'How Often',
            ),
            _buildDropdown<MealTime>(
              value: _selectedMealTime,
              onChanged: (value) {
                setState(() {
                  _selectedMealTime = value!;
                });
              },
              items: MealTime.values,
              labelText: 'Meal Time',
            ),
            Row(
              children: [
                const Text('Start Date: '),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedStartDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null &&
                        pickedDate != _selectedStartDate) {
                      setState(() {
                        _selectedStartDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    '${_selectedStartDate.toLocal()}'.split(' ')[0],
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('End Date: '),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedEndDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _selectedEndDate) {
                      setState(() {
                        _selectedEndDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    '${_selectedEndDate.toLocal()}'.split(' ')[0],
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final newMedicine = Medicine(
                  name: _nameController.text,
                  type: _selectedType,
                  frequency: _selectedFrequency,
                  howOften: _selectedHowOften,
                  mealTime: _selectedMealTime,
                  startDate: _selectedStartDate,
                  endDate: _selectedEndDate,
                  index: widget.initialMedicine?.index,
                );
                widget.onDetailsSubmitted(newMedicine);
                Navigator.pop(context);
              },
              child: Text(widget.initialMedicine != null
                  ? 'Update Medicine'
                  : 'Add Medicine'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required void Function(T?) onChanged,
    required List<T> items,
    required String labelText,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item.toString().split('.').last),
        );
      }).toList(),
      decoration: InputDecoration(labelText: labelText),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyMedicinesPage(),
  ));
}

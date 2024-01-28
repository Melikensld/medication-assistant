import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appointment {
  String doctorName = '';
  DateTime visitDate = DateTime.now();
  String hospitalVisited = '';
  String medicinesTaken = '';

  Appointment({
    required this.doctorName,
    required this.visitDate,
    required this.hospitalVisited,
    required this.medicinesTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorName': doctorName,
      'visitDate': visitDate.toIso8601String(),
      'hospitalVisited': hospitalVisited,
      'medicinesTaken': medicinesTaken,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      doctorName: map['doctorName'],
      visitDate: DateTime.parse(map['visitDate']),
      hospitalVisited: map['hospitalVisited'],
      medicinesTaken: map['medicinesTaken'],
    );
  }

  // JSON Serialization
  String toJson() => json.encode(toMap());

  // JSON Deserialization
  factory Appointment.fromJson(String jsonStr) =>
      Appointment.fromMap(json.decode(jsonStr));
}

class MyAppointmentsPage extends StatefulWidget {
  @override
  _MyAppointmentsPageState createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  List<Appointment> appointments = [];
  TextEditingController doctorNameController = TextEditingController();
  TextEditingController visitDateController = TextEditingController();
  TextEditingController hospitalController = TextEditingController();
  TextEditingController medicinesController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool sortByDate = true;

  List<String> doctorNames = [
    'Prof. Dr. Gazi Yaşargil',
    'Prof. Dr. Münci Kalayoğlu',
    'Prof. Dr. Ömer Özkan',
    'Prof. Dr. Hande Özdinler',
  ];

  List<String> hospitalNames = [
    'Eskişehir Şehir Hastanesi',
    'Yunus Emre Devlet Hastanesi',
    'Çifteler Devlet Hastanesi',
    'Sivrihisar Devlet Hastanesi',
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void dispose() {
    _saveAppointments();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              setState(() {
                sortByDate = !sortByDate;
                _sortAppointments();
              });
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchInput(),
            Expanded(
              child: _buildAppointmentsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAppointmentDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Search by doctor name or date',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    List<Appointment> filteredAppointments = _filterAppointments();
    return ListView.builder(
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[200],
          child: ListTile(
            title: Text(filteredAppointments[index].doctorName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Visit Date: ${filteredAppointments[index].visitDate.toLocal()}'),
                Text(
                    'Hospital Visited: ${filteredAppointments[index].hospitalVisited}'),
                Text(
                    'Medicines Taken: ${filteredAppointments[index].medicinesTaken}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteAppointment(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String selectedDoctor =
            doctorNames[0]; 
        String selectedHospital =
            hospitalNames[0]; 

        return AlertDialog(
          title: Text('Add Appointment'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDoctor,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDoctor = newValue!;
                    });
                  },
                  items:
                      doctorNames.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Doctor Name'),
                ),
                TextField(
                  controller: visitDateController,
                  decoration: InputDecoration(labelText: 'Visit Date'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null && pickedDate != DateTime.now()) {
                      setState(() {
                        visitDateController.text = pickedDate.toString();
                      });
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedHospital,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedHospital = newValue!;
                    });
                  },
                  items: hospitalNames
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Hospital Visited'),
                ),
                TextField(
                  controller: medicinesController,
                  decoration: InputDecoration(labelText: 'Medicines Taken'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  doctorNameController.text = selectedDoctor;
                  hospitalController.text = selectedHospital;
                });
                _addAppointment();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addAppointment() {
    Appointment newAppointment = Appointment(
      doctorName: doctorNameController.text,
      visitDate: DateTime.parse(visitDateController.text),
      hospitalVisited: hospitalController.text,
      medicinesTaken: medicinesController.text,
    );

    setState(() {
      appointments.add(newAppointment);
      _sortAppointments();
      _clearControllers();
    });
  }

  List<Appointment> _filterAppointments() {
    String searchTerm = searchController.text.toLowerCase();
    List<Appointment> filteredAppointments = [];

    for (Appointment appointment in appointments) {
      if (appointment.doctorName.toLowerCase().contains(searchTerm) ||
          appointment.visitDate.toString().contains(searchTerm)) {
        filteredAppointments.add(appointment);
      }
    }

    return filteredAppointments;
  }

  void _sortAppointments() {
    if (sortByDate) {
      appointments.sort((a, b) => a.visitDate.compareTo(b.visitDate));
    } else {
      appointments.sort((a, b) => a.doctorName.compareTo(b.doctorName));
    }
  }

  void _loadAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? appointmentStrings = prefs.getStringList('appointmentsKey');

    if (appointmentStrings != null) {
      List<Appointment> loadedAppointments =
          appointmentStrings.map((appointmentStr) {
        return Appointment.fromJson(appointmentStr);
      }).toList();

      setState(() {
        appointments = loadedAppointments;
        _sortAppointments();
      });
    }
  }

  void _saveAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> appointmentStrings = appointments.map((appointment) {
      return appointment.toJson();
    }).toList();

    prefs.setStringList('appointmentsKey', appointmentStrings);
  }

  void _deleteAppointment(int index) {
    setState(() {
      appointments.removeAt(index);
      _sortAppointments();
      _saveAppointments();
    });
  }

  void _clearControllers() {
    doctorNameController.clear();
    visitDateController.clear();
    hospitalController.clear();
    medicinesController.clear();
  }
}

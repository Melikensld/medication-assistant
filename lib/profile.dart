import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataService with ChangeNotifier {
  String _userName = 'Melike Ünsaldı';
  int _userAge = 22;
  int _userWeight = 70;
  double _userHeight = 1.72;
  String _userCity = 'Eskişehir';
  String _healthCenter = 'Eskişehir 001';

  String get userName => _userName;
  int get userAge => _userAge;
  int get userWeight => _userWeight;
  double get userHeight => _userHeight;
  String get userCity => _userCity;
  String get healthCenter => _healthCenter;

  UserDataService() {
    _loadUserData();
  }

  void updateUserData({
    required String name,
    required int age,
    required int weight,
    required double height,
    required String city,
    required String healthCenter,
  }) {
    _userName = name;
    _userAge = age;
    _userWeight = weight;
    _userHeight = height;
    _userCity = city;
    _healthCenter = healthCenter;

    _saveUserData();
    notifyListeners();
  }

  // Load user data from shared preferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? _userName;
    _userAge = prefs.getInt('userAge') ?? _userAge;
    _userWeight = prefs.getInt('userWeight') ?? _userWeight;
    _userHeight = prefs.getDouble('userHeight') ?? _userHeight;
    _userCity = prefs.getString('userCity') ?? _userCity;
    _healthCenter = prefs.getString('healthCenter') ?? _healthCenter;

    notifyListeners();
  }

  // Save user data to shared preferences
  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', _userName);
    prefs.setInt('userAge', _userAge);
    prefs.setInt('userWeight', _userWeight);
    prefs.setDouble('userHeight', _userHeight);
    prefs.setString('userCity', _userCity);
    prefs.setString('healthCenter', _healthCenter);
  }
}


class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserDataService(),
      child: Center(
        child: _ProfilePage(),
      ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController cityController;
  late TextEditingController healthCenterController;

  @override
  void initState() {
    super.initState();
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    nameController = TextEditingController(text: userDataService.userName);
    ageController = TextEditingController(text: userDataService.userAge.toString());
    weightController = TextEditingController(text: userDataService.userWeight.toString());
    heightController = TextEditingController(text: userDataService.userHeight.toString());
    cityController = TextEditingController(text: userDataService.userCity);
    healthCenterController = TextEditingController(text: userDataService.healthCenter);
  }

  @override
  Widget build(BuildContext context) {
    final userDataService = Provider.of<UserDataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            
              const Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/default_profile.jpg'),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('${userDataService.userName}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Age: ${userDataService.userAge} years', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Weight: ${userDataService.userWeight} lbs', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Height: ${userDataService.userHeight}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('City: ${userDataService.userCity}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Health Center: ${userDataService.healthCenter}', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditDialog(context, userDataService);
        },
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  _showEditDialog(BuildContext context, UserDataService userDataService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name Surname'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Weight'),
                ),
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(labelText: 'Height'),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: healthCenterController,
                  decoration: const InputDecoration(labelText: 'Health Center'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                userDataService.updateUserData(
                  name: nameController.text,
                  age: int.tryParse(ageController.text) ?? 0,
                  weight: int.tryParse(weightController.text) ?? 0,
                  height: double.tryParse(heightController.text) ?? 0,
                  city: cityController.text,
                  healthCenter: healthCenterController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

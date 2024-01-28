import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'my_medicines.dart';
import 'my_schedule.dart';
import 'my_appointments.dart';
import 'my_notes.dart';
import 'profile.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.userCircle),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCard(
                  context,
                  'My Medicines',
                  FontAwesomeIcons.pills,
                  MyMedicinesPage(),
                ),
                buildCard(
                  context,
                  'My Schedule',
                  FontAwesomeIcons.clock,
                  MySchedulePage(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCard(
                  context,
                  'My Appointments',
                  FontAwesomeIcons.stethoscope,
                  MyAppointmentsPage(),
                ),
                buildCard(
                  context,
                  'My Notes',
                  FontAwesomeIcons.stickyNote,
                  MyNotesPage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 5.0,
        margin: EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.35,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60.0),
              SizedBox(height: 5.0),
              Text(
                title,
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

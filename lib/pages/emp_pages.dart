// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:new_attendance_manager/pages/calendar_page.dart';
import 'package:new_attendance_manager/pages/home_page.dart';
import 'package:new_attendance_manager/pages/profile_page.dart';

class EmpPages extends StatefulWidget {
  const EmpPages({super.key});

  @override
  State<EmpPages> createState() => _EmpPagesState();
}

class _EmpPagesState extends State<EmpPages> {
  int currentIndex = 0;

  List<IconData> navigationIcons = [
    Icons.home,
    Icons.calendar_today,
    Icons.person
  ];

  List navigationTitles = ["Home", "Presence", "Profile"];

  void getDocId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('name', isEqualTo: Users.empName)
        .get();

    setState(() {
      Users.docID = snap.docs[0].id;
    });
  }

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    getDocId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomePage(),
          CalendarPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 15, right: 20, left: 20),
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.cyan,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = i;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  width: 50,
                  color: Colors.cyan,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        navigationIcons[i],
                        color:
                            i == currentIndex ? Colors.white : Colors.grey[300],
                        size: i == currentIndex ? 30 : 24,
                      ),
                      Text(
                        navigationTitles[i],
                        style: TextStyle(
                          color: i == currentIndex
                              ? Colors.white
                              : Colors.grey[300],
                          fontSize: i == currentIndex ? 17 : 14,
                        ),
                      )
                    ],
                  ),
                ),
              ))
            }
          ],
        ),
      ),
    );
  }
}

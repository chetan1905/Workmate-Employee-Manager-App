// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:new_attendance_manager/chatapp/chat_login_status.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:new_attendance_manager/pages/login_page.dart';
import 'package:new_attendance_manager/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:sprintf/sprintf.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String checkIn = '00:00:00 AM';
  String checkOut = '00:00:00 AM';
  bool workFromOffice = false;
  bool workFromHome = false;
  String agenda = "No Agenda for today";
  String assignedTask = "No task assigned";
  late SharedPreferences sharedPreferences;
  TextEditingController agendaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _getRecord();
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('name', isEqualTo: Users.empName)
          .get();
      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Records")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();
      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
        workFromHome = snap2['wfh'];
        workFromOffice = snap2['wfo'];
        agenda = snap2['agenda'];
        assignedTask = snap2['assignedtask'];
      });
    } catch (e) {
      setState(() {
        checkIn = '00:00:00 AM';
        checkOut = '00:00:00 AM';
        workFromHome = false;
        workFromOffice = false;
        agenda = "No Agenda for today";
        assignedTask = "No task assigned";
      });
    }
  }

  Future<void> signOut() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear().then((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  String getHoursWorked(String checkInTime, String checkOutTime) {
    DateTime checkIn = DateFormat('hh:mm:ss a').parse(checkInTime);
    DateTime checkOut = DateFormat('hh:mm:ss a').parse(checkOutTime);

    Duration duration = checkOut.difference(checkIn);

    int hours = duration.inMinutes ~/ 60;
    int minutes = (duration.inMinutes % 60).toInt();
    String formattedDuration = sprintf("%d Hrs:%02d Min", [hours, minutes]);
    return formattedDuration;
  }

  Duration checkDuration(String checkInTime, String checkOutTime) {
    String durationString = getHoursWorked(checkInTime, checkOutTime);
    Duration duration = Duration(
        hours: int.parse(durationString.split(' ')[0]),
        minutes: int.parse(durationString.split(':')[1].split(' ')[0]));
    return duration;
  }

  String currentAddress = 'My Address';
  late Position currentposition;
  late String myLocation;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      // Get the address of the current location using the Geocoding API
      List<Placemark> addresses = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: Platform.localeName);
      String address = addresses[0].name ?? '';

      setState(() {
        currentposition = position;
        currentAddress =
            "$address, ${place.postalCode}, ${place.locality}, ${place.country}";
      });
    } catch (e) {}

    return position;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.cyan,
            elevation: 0.0,
            leadingWidth: 250,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome!",
                    style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: 18),
                  ),
                  Text(
                    Users.empName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () => _openDrawer(),
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 32,
                  ))
            ],
          ),
          endDrawer: Drawer(
            elevation: 0.0,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      Users.empName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.chat,
                    color: Colors.cyan,
                  ),
                  title: Text(
                    'CHAT',
                    style: TextStyle(
                        color: Colors.cyan, fontStyle: FontStyle.italic),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatLoginStatus()));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.location_history,
                    color: Colors.cyan,
                  ),
                  title: Text(
                    'LOCATION',
                    style: TextStyle(
                        color: Colors.cyan, fontStyle: FontStyle.italic),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    _determinePosition().then((_) {
                      setState(() {
                        myLocation = currentAddress;
                      });
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Your Currect Location"),
                              titleTextStyle:
                                  TextStyle(color: Colors.cyan, fontSize: 18),
                              content: Text(currentAddress),
                              contentTextStyle: TextStyle(color: Colors.cyan),
                            );
                          });
                    });
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.note_add,
                    color: Colors.cyan,
                  ),
                  title: Text(
                    'AGENDA',
                    style: TextStyle(
                        color: Colors.cyan, fontStyle: FontStyle.italic),
                  ),
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AlertDialog(
                        titleTextStyle: TextStyle(
                            color: Colors.cyan,
                            fontSize: 22,
                            fontStyle: FontStyle.italic),
                        title: Text("TODAY's AGENDA"),
                        content: SizedBox(
                          width: 300,
                          child: CustomField(
                              controller: agendaController,
                              labelText: null,
                              obscureText: false,
                              suffixIcon: null),
                        ),
                        actions: [
                          GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10),
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      color: Colors.cyan, fontSize: 24),
                                ),
                              ))
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.today_outlined,
                    color: Colors.cyan,
                  ),
                  title: Text(
                    'ASSIGNED TASK',
                    style: TextStyle(
                        color: Colors.cyan, fontStyle: FontStyle.italic),
                  ),
                  onTap: () async {
                    QuerySnapshot snap = await FirebaseFirestore.instance
                        .collection("Employee")
                        .where('name', isEqualTo: Users.empName)
                        .get();
                    showDialog(
                      context: context,
                      builder: (context) => StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Employee')
                            .doc(snap.docs[0].id)
                            .collection('Records')
                            .doc(DateFormat('dd MMMM yyyy')
                                .format(DateTime.now()))
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final recordData =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          if (recordData == null) {
                            return AlertDialog(
                              title: Text("No Task Assigned Yet"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          final assignedTask =
                              recordData['assignedtask'] as String?;

                          if (assignedTask == null) {
                            return AlertDialog(
                              title: Text("No Task Assigned Yet"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return AlertDialog(
                            titleTextStyle: TextStyle(
                                color: Colors.cyan,
                                fontSize: 22,
                                fontStyle: FontStyle.italic),
                            title: Text("YOUR TASK"),
                            content: Text(assignedTask),
                            actions: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 10),
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                        color: Colors.cyan, fontSize: 24),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.cyan,
                  ),
                  title: Text(
                    'LOGOUT',
                    style: TextStyle(
                        color: Colors.cyan, fontStyle: FontStyle.italic),
                  ),
                  onTap: () {
                    signOut();
                  },
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 130, vertical: 20),
                  child: Text(
                    "Today's Status",
                    style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.cyan,
                            blurRadius: 10,
                            offset: Offset(2, 2))
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "DATE",
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 24,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy')
                                .format(DateTime.now())
                                .toString(),
                            style: TextStyle(
                                color: Colors.cyan,
                                fontSize: 22,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "TIME",
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 24,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 1)),
                              builder: (context, snapshot) {
                                return Text(
                                  DateFormat('hh:mm:ss a')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400),
                                );
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.cyan,
                            blurRadius: 10,
                            offset: Offset(2, 2))
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Check In",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400]),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            checkIn,
                            style: TextStyle(color: Colors.cyan, fontSize: 24),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Check Out",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[400])),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            checkOut,
                            style: TextStyle(color: Colors.cyan, fontSize: 24),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                (workFromHome == false && workFromOffice == false)
                    ? Column(
                        children: [
                          Text(
                            "Today, you are on...",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 18),
                          ),
                          Container(
                            height: 120,
                            margin: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 80),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.cyan,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      workFromOffice = true;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white30,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Work From Office",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      workFromHome = true;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white30,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Work From Home",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                            "Today, you are on...",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 18),
                          ),
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 80),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: workFromHome == true
                                ? Container(
                                    height: 50,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white30,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Work From Home",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                  )
                                : Container(
                                    height: 50,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white30,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Work From Office",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                checkOut == '00:00:00 AM'
                    ? Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Builder(builder: (context) {
                          final GlobalKey<SlideActionState> key = GlobalKey();

                          return SlideAction(
                            text: checkIn == '00:00:00 AM'
                                ? "Slide to Check In"
                                : "Slide to Check Out",
                            textStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                            outerColor: Colors.white,
                            innerColor: Colors.cyan,
                            key: key,
                            onSubmit: () async {
                              await Future.delayed(Duration(seconds: 1))
                                  .then((value) => key.currentState!.reset());

                              QuerySnapshot snap = await FirebaseFirestore
                                  .instance
                                  .collection("Employee")
                                  .where('name', isEqualTo: Users.empName)
                                  .get(); // written so as to fetch the document id of the current user and save it in snap variable.

                              DocumentSnapshot snap2 = await FirebaseFirestore
                                  .instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("Records")
                                  .doc(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()))
                                  .get();

                              try {
                                Duration workedDuration = checkDuration(
                                    snap2['checkIn'],
                                    DateFormat('hh:mm:ss a')
                                        .format(DateTime.now()));

                                if (workedDuration.inHours < 8) {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Duration Warning!!',
                                            style:
                                                TextStyle(color: Colors.cyan)),
                                        content: Text(
                                          'You have only worked for ${getHoursWorked(snap2['checkIn'], DateFormat('hh:mm:ss a').format(DateTime.now()))}, which is less than 8 hours. So, you\'ll be paid accordingly. Are you sure you want to CheckOut ?',
                                          style: TextStyle(
                                              color: Colors.grey[400]),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              'YES',
                                              style:
                                                  TextStyle(color: Colors.cyan),
                                            ),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection("Employee")
                                                  .doc(snap.docs[0].id)
                                                  .collection('Records')
                                                  .doc(DateFormat(
                                                          'dd MMMM yyyy')
                                                      .format(DateTime.now()))
                                                  .update({
                                                'date': Timestamp.now(),
                                                'checkOut':
                                                    DateFormat('hh:mm:ss a')
                                                        .format(DateTime.now()),
                                              });

                                              setState(() {
                                                checkOut =
                                                    DateFormat('hh:mm:ss a')
                                                        .format(DateTime.now());
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'NO',
                                                style: TextStyle(
                                                    color: Colors.cyan),
                                              ))
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection("Employee")
                                      .doc(snap.docs[0].id)
                                      .collection('Records')
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .update({
                                    'date': Timestamp.now(),
                                    'checkOut': DateFormat('hh:mm:ss a')
                                        .format(DateTime.now()),
                                  });

                                  setState(() {
                                    checkOut = DateFormat('hh:mm:ss a')
                                        .format(DateTime.now());
                                  });
                                }
                              } catch (e) {
                                await FirebaseFirestore.instance
                                    .collection("Employee")
                                    .doc(snap.docs[0].id)
                                    .collection("Records")
                                    .doc(DateFormat('dd MMMM yyyy')
                                        .format(DateTime.now()))
                                    .set({
                                  'date': Timestamp.now(),
                                  'checkIn': DateFormat('hh:mm:ss a')
                                      .format(DateTime.now()),
                                  'checkOut': '00:00:00 AM',
                                  'wfo': workFromOffice,
                                  'wfh': workFromHome,
                                  'agenda': agendaController.text.trim(),
                                  'assignedtask': assignedTask,
                                  'myLocation': myLocation
                                });

                                setState(() {
                                  checkIn = DateFormat('hh:mm:ss a')
                                      .format(DateTime.now());
                                });
                              }
                            },
                          );
                        }),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Already checked out for today",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400]),
                        ),
                      ),
              ],
            ),
          )),
    );
  }
}

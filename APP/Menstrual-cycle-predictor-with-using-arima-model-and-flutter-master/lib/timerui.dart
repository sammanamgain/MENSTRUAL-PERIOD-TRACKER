import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'data/database.dart';
import 'retrive/retrievedata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menstrual_period_tracker/screens/calendar.dart';
import 'package:menstrual_period_tracker/screens/content.dart';
import 'package:menstrual_period_tracker/screens/stat.dart';
import 'package:menstrual_period_tracker/symptoms.dart';

import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:menstrual_period_tracker/notifications/notifications.dart';

import 'loginsignup/signup.dart';
//import 'package:nepali_date_converter/nepali_date_converter.dart';

class MyApps extends StatefulWidget {
  bool predictAgain = true;
  final String? email;
  MyApps(this.email, {this.predictAgain = true});

  @override
  State<MyApps> createState() => _MyAppsState();
}

class _MyAppsState extends State<MyApps> {
  int? age;
  final _url = 'http://10.0.2.2:5000/forecast';
  NepaliDateTime previousDate = NepaliDateTime.now();
  DateTime previous = DateTime.now();
  @override
  void initState() {
    super.initState();
    NotificationAPI.init();
  }
  //_makeForecast();

  NepaliDateTime _dateTime = NepaliDateTime.now();
  var impdata;
  void _showdatepicker(String Datevalue) async {
    await showMaterialDatePicker(
      context: context,
      initialDate: NepaliDateTime.now(),
      firstDate: NepaliDateTime(2078),
      lastDate: NepaliDateTime(2090),
    ).then((value) {
      if (value == null) {
        print('Date picker was cancelled');
        return;
      }
      NepaliDateTime? updatevalue = NepaliDateTime.tryParse(value.toString());
      setState(() {
        _dateTime = updatevalue!;
        NepaliUnicode.convert('value');
      });

      //'${now.year}-${now.month}-${now.day}'
      NepaliDateTime? date2;
      //if (Datevalue != null) {
      date2 = NepaliDateTime.parse(Datevalue);
      //} else {}

      NepaliDateTime now = NepaliDateTime.now();
      Duration difference = _dateTime.difference(date2);
      int cycleLength = difference.inDays;
      addCycleData(
          widget.email, cycleLength, '${now.year}-${now.month}-${now.day}');
      //Below Function just Check Garna Ko lagi Banayeko
      addPeriodDate(widget.email,
          '${_dateTime.year}-${_dateTime.month}-${_dateTime.day}');
    });
  }

  String? result;
  var a = 0;
  dynamic finalinput = [];
  void makeForecast() async {
    // Define the input data as a list of dictionaries
    var inputData = [
      for (var i = 0; i < finalinput.length; i++)
        {
          "date": 2022 - 01 - i,
          "value": finalinput[i],
          "age": age! + i,
        }
    ];

    // Send a POST request to the Flask API
    var response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'data': inputData}),
    );

    // Parse the response as a JSON string
    var responseData = json.decode(response.body);

    setState(() {
      result = responseData.toInt().toString();
    });

    value = true;
  }

  var value = false;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    if (value == true) {
      Duration diff = _dateTime.difference(previousDate);
      int d = diff.inDays;

      int x = int.parse(result!);
      int y = x - d;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference collection = firestore.collection('User Details');

      DocumentReference document = collection.doc(widget.email);
      document.set({'Prediction': x}, SetOptions(merge: true));
      document.set({'Prediction Date': previousDate}, SetOptions(merge: true));

      if (y <= 0) {
        if (y == 0) {
          y = -1;
        } else if (y == -5) {
          NepaliDateTime now = NepaliDateTime.now();
          now = now.add(Duration(days: y));
          addPeriodDate2(widget.email, '${now.year}-${now.month}-${now.day}');
        }

        y = y * -1;
        NotificationAPI.stopNotification();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "टाइमर",
              style: GoogleFonts.getFont(
                'Khand',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 253, 250, 250),
              ),
            ),
            backgroundColor: Color.fromARGB(255, 66, 13, 106),
            toolbarHeight: 80,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: w * 0.7,
                    height: h * 0.4,
                    child: Column(
                      //  mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: w,
                          height: h * 0.01,
                        ),
                        Center(
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 154, 58, 58),
                              radius: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                    child: Text(
                                      "महिनावारी ",
                                      style: GoogleFonts.getFont(
                                        'Khand',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 5, 5, 5),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: h * 0.03,
                                    width: w,
                                  ),
                                  Text(
                                    y.toString(),
                                    style: TextStyle(
                                        fontSize: 32, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: h * 0.10,
                    width: w,
                  ),
                  // SizedBox(
                  //   height: h * 0.06,
                  //   width: w,
                  // ),
                  FutureBuilder<RetrieveData?>(
                      future: retrieveUSERData(widget.email!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final USER = snapshot.data!;
                          return Container(
                            width: w * 0.7,
                            height: h * 0.2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'महिनावारीको मिति परिवर्तन गर्न',
                                  style: GoogleFonts.getFont(
                                    'Khand',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 5, 5, 5),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.03,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(39, 3, 27, 0.686),
                                  ),
                                  onPressed: () async {
                                    //    RetrieveData? x =
                                    final String periodDate =
                                        await retrievePeriodDates2(
                                            widget.email);
                                    uilength(widget.email);
                                    // print(periodDate);
                                    _showdatepicker(periodDate);
                                    // print(periodDate);
                                    //_showdatepicker(periodDate);
                                    //retrievePeriodDates(widget.email);
                                  },
                                  child: Center(
                                    child: Text(
                                      "मिति छान्नु होस्",
                                      style: GoogleFonts.getFont(
                                        'Khand',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 253, 250, 250),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text("Loading Data");
                        }
                      }),
                ],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor:
                Color.fromARGB(255, 66, 13, 106), // set background color
            type: BottomNavigationBarType.fixed, // set type to fixed
            selectedItemColor: Colors.white, // set selected item color
            unselectedItemColor: Colors.grey[400], // set unselected item color
            iconSize: 30, // set icon sizeincrease the size of the icons
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => MyApps(widget.email));
                  },
                  child: const Icon(Icons.timer),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => Calendar(widget.email));
                  },
                  child: const Icon(Icons.calendar_month),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => MyHomePage(widget.email));
                  },
                  child: const Icon(Icons.girl_sharp),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => Stat(widget.email));
                  },
                  child: const Icon(Icons.auto_graph),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => Content(widget.email));
                  },
                  child: const Icon(Icons.content_copy),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
            ],
          ),
        );
      } else {
        NotificationAPI.showScheduledDate2Notification(
            title: 'Period Tracker',
            body: 'Your Period is near. Check the app to know more',
            scheduledDate: DateTime.now().add(Duration(days: y - 5)));

        //   else{
        //     for(int i = 0; i<y;i++){
        //     NotificationAPI.showScheduledNotification(
        //     title:'Period Tracker',
        //     body:'Your Period is in ${(y-i).toString()} days',
        //     scheduledDate: DateTime.now().add(Duration(days: y-i))
        //   );
        //     }}
        // NotificationAPI.showNotification(
        //   body: "test",
        //   title: 'test ${y.toString()}',
        //   payload: 'test',
        // );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "टाइमर",
              style: GoogleFonts.getFont(
                'Khand',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 253, 250, 250),
              ),
            ),
            backgroundColor: Color.fromARGB(255, 66, 13, 106),
            toolbarHeight: 80,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: h * 0.5,
                    child: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 154, 58, 58),
                      radius: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: Text(
                              "महिनावारी आउन बाँकी दिन",
                              style: GoogleFonts.getFont(
                                'Khand',
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 5, 5, 5),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: h * 0.03,
                            width: w,
                          ),
                          Text(
                            y.toString(),
                            style: TextStyle(fontSize: 32, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: h * 0.10,
                  //   width: w,
                  // ),
                  // SizedBox(
                  //   height: h * 0.06,
                  //   width: w,
                  // ),
                  FutureBuilder<RetrieveData?>(
                      future: retrieveUSERData(widget.email!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final USER = snapshot.data!;
                          return Center(
                            child: Container(
                              width: w * 0.7,
                              height: h * 0.2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'महिनावारीको मिति परिवर्तन गर्न',
                                    style: GoogleFonts.getFont(
                                      'Khand',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 5, 5, 5),
                                    ),
                                  ),
                                  SizedBox(
                                    height: h * 0.03,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(39, 3, 27, 0.686),
                                    ),
                                    onPressed: () async {
                                      //    RetrieveData? x =
                                      // await retrieveUSERData(widget.email!);
                                      //  print(x?.age);

                                      //String Datevalues = retrievePeriodDates(widget.email).toString();
                                      final String periodDate =
                                          await retrievePeriodDates2(
                                              widget.email);
                                      uilength(widget.email);
                                      // print(periodDate);
                                      _showdatepicker(periodDate);
                                      //retrievePeriodDates(widget.email);
                                    },
                                    child: Center(
                                      child: Text(
                                        "मिति छान्नु होस्",
                                        style: GoogleFonts.getFont(
                                          'Khand',
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 253, 250, 250),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Text("Loading Data");
                        }
                      }),
                ],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor:
                Color.fromARGB(255, 66, 13, 106), // set background color
            type: BottomNavigationBarType.fixed, // set type to fixed
            selectedItemColor: Colors.white, // set selected item color
            unselectedItemColor: Colors.grey[400], // set unselected item color
            iconSize: 30, // set icon sizeincrease the size of the icons
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => MyApps(widget.email));
                  },
                  child: const Icon(Icons.timer),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => Calendar(widget.email));
                  },
                  child: const Icon(Icons.calendar_month),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => MyHomePage(widget.email));
                  },
                  child: const Icon(Icons.girl_sharp),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => Stat(widget.email));
                  },
                  child: const Icon(Icons.auto_graph),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Get.to(() => Content(widget.email));
                  },
                  child: const Icon(Icons.content_copy),
                ),
                label: '',
                backgroundColor: const Color.fromARGB(255, 66, 13, 106),
              ),
            ],
          ),
        );
      }
    } else if (widget.predictAgain == false) {
      return FutureBuilder<RetrieveData?>(
          future: retrieveUSERData(widget.email!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final test = snapshot.data!;
              result = test.prediction.toString();
              Duration diff = _dateTime.difference(previousDate);
              int d = diff.inDays;

              int x = int.parse(result!);
              int y = x - d;

              if (y <= 0) {
                NotificationAPI.stopNotification();
                y = y * -1;
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "टाइमर",
                      style: GoogleFonts.getFont(
                        'Khand',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 253, 250, 250),
                      ),
                    ),
                    backgroundColor: Color.fromARGB(255, 66, 13, 106),
                    toolbarHeight: 80,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                  ),
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: w * 0.7,
                            height: h * 0.4,
                            child: Column(
                              //  mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Center(
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Color.fromARGB(255, 12, 12, 12),
                                      radius: 155,
                                      // child:
                                      child: Column(
                                        children: [
                                          Text(
                                              "Peiod Running. Day is ${y.toString()}"),
                                        ],
                                      ),
                                    ), //CircleAvatar
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: h * 0.10,
                            width: w,
                          ),
                          SizedBox(
                            height: h * 0.06,
                            width: w,
                          ),
                          FutureBuilder<RetrieveData?>(
                              future: retrieveUSERData(widget.email!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final USER = snapshot.data!;
                                  return Container(
                                    width: w * 0.7,
                                    height: h * 0.2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'महिनावारीको मिति परिवर्तन गर्न',
                                          style: GoogleFonts.getFont(
                                            'Khand',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 5, 5, 5),
                                          ),
                                        ),
                                        SizedBox(
                                          height: h * 0.03,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromRGBO(
                                                39, 3, 27, 0.686),
                                          ),
                                          onPressed: () async {
                                            //    RetrieveData? x =
                                            final String periodDate =
                                                await retrievePeriodDates2(
                                                    widget.email);
                                            uilength(widget.email);
                                            // print(periodDate);
                                            _showdatepicker(periodDate);
                                            // print(periodDate);
                                            //_showdatepicker(periodDate);
                                            //retrievePeriodDates(widget.email);
                                          },
                                          child: Center(
                                            child: Text(
                                              "मिति छान्नु होस्",
                                              style: GoogleFonts.getFont(
                                                'Khand',
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 253, 250, 250),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Text("Loading Data");
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    backgroundColor: Color.fromARGB(
                        255, 66, 13, 106), // set background color
                    type: BottomNavigationBarType.fixed, // set type to fixed
                    selectedItemColor: Colors.white, // set selected item color
                    unselectedItemColor:
                        Colors.grey[400], // set unselected item color
                    iconSize: 30, // set icon sizeincrease the size of the icons
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => MyApps(widget.email));
                          },
                          child: const Icon(Icons.timer),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => Calendar(widget.email));
                          },
                          child: const Icon(Icons.calendar_month),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => MyHomePage(widget.email));
                          },
                          child: const Icon(Icons.girl_sharp),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => Stat(widget.email));
                          },
                          child: const Icon(Icons.auto_graph),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => Content(widget.email));
                          },
                          child: const Icon(Icons.content_copy),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                    ],
                  ),
                );
              } else {
                //NotificationAPI.stopNotification();

                // if (y <= 5) {
                //   NotificationAPI.showScheduledNotification(
                //     title: 'Period Tracker',
                //     body: 'Your Period is near. Check the app to know more',
                //   );
                // }
                // NotificationAPI.showScheduledDate2Notification(
                //     title: 'Period Tracker',
                //     body: 'Your Period is near. Check the app to know more',
                //     scheduledDate: DateTime.now().add(Duration(days: y - 5)));

                //   else{
                //     for(int i = 0; i<y;i++){
                //     NotificationAPI.showScheduledNotification(
                //     title:'Period Tracker',
                //     body:'Your Period is in ${(y-i).toString()} days',
                //     scheduledDate: DateTime.now().add(Duration(days: y-i))
                //   );
                //     }}
                //  NotificationAPI.showNotification(
                //    body: "test",
                //    title: 'test ${y.toString()}',
                //    payload: 'test',
                //  );

                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "टाइमर",
                      style: GoogleFonts.getFont(
                        'Khand',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 253, 250, 250),
                      ),
                    ),
                    backgroundColor: Color.fromARGB(255, 66, 13, 106),
                    toolbarHeight: 80,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                  ),
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: h * 0.5,
                            child: CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 154, 58, 58),
                              radius: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                    child: Text(
                                      "महिनावारी आउन बाँकी दिन",
                                      style: GoogleFonts.getFont(
                                        'Khand',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 5, 5, 5),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: h * 0.03,
                                    width: w,
                                  ),
                                  Text(
                                    y.toString(),
                                    style: TextStyle(
                                        fontSize: 32, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: h * 0.10,
                          //   width: w,
                          // ),
                          // SizedBox(
                          //   height: h * 0.06,
                          //   width: w,
                          // ),
                          FutureBuilder<RetrieveData?>(
                              future: retrieveUSERData(widget.email!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final USER = snapshot.data!;
                                  return Center(
                                    child: Container(
                                      width: w * 0.7,
                                      height: h * 0.2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'महिनावारीको मिति परिवर्तन गर्न',
                                            style: GoogleFonts.getFont(
                                              'Khand',
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color.fromARGB(255, 5, 5, 5),
                                            ),
                                          ),
                                          SizedBox(
                                            height: h * 0.03,
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromRGBO(
                                                  39, 3, 27, 0.686),
                                            ),
                                            onPressed: () async {
                                              //    RetrieveData? x =
                                              // await retrieveUSERData(widget.email!);
                                              //  print(x?.age);

                                              //String Datevalues = retrievePeriodDates(widget.email).toString();
                                              final String periodDate =
                                                  await retrievePeriodDates2(
                                                      widget.email);
                                              uilength(widget.email);
                                              // print(periodDate);
                                              _showdatepicker(periodDate);
                                              //retrievePeriodDates(widget.email);
                                            },
                                            child: Center(
                                              child: Text(
                                                "मिति छान्नु होस्",
                                                style: GoogleFonts.getFont(
                                                  'Khand',
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 253, 250, 250),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Text("Loading Data");
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    backgroundColor: Color.fromARGB(
                        255, 66, 13, 106), // set background color
                    type: BottomNavigationBarType.fixed, // set type to fixed
                    selectedItemColor: Colors.white, // set selected item color
                    unselectedItemColor:
                        Colors.grey[400], // set unselected item color
                    iconSize: 30, // set icon sizeincrease the size of the icons
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => MyApps(widget.email));
                          },
                          child: const Icon(Icons.timer),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => Calendar(widget.email));
                          },
                          child: const Icon(Icons.calendar_month),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => MyHomePage(widget.email));
                          },
                          child: const Icon(Icons.girl_sharp),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => Stat(widget.email));
                          },
                          child: const Icon(Icons.auto_graph),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            Get.to(() => Content(widget.email));
                          },
                          child: const Icon(Icons.content_copy),
                        ),
                        label: '',
                        backgroundColor: const Color.fromARGB(255, 66, 13, 106),
                      ),
                    ],
                  ),
                );
              }
            } else {
              return Text("");
            }
          });
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "टाइमर",
            style: GoogleFonts.getFont(
              'Khand',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 253, 250, 250),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 66, 13, 106),
          toolbarHeight: 80,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  FutureBuilder<RetrieveData?>(
                      future: retrieveUSERData(widget.email!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final USER = snapshot.data!;

                          //   final USER2 = snapshot.data!;
                          //    print("printing age");

                          age = USER.age;
                          finalinput = USER.cycleLength;
                          //    print(age);
                          //   print("printing cyclelength");
                          //  impdata = USER.cycleLength;
                          //   print(impdata);
                          //     print("cyclelength");

                          previousDate = NepaliDateTime.parse(USER.periodDate!);
                          //    print(previousDate);

                          DateTime dt = previousDate.toDateTime();
                          previous = dt as DateTime;

                          String N = DateFormat('yyyy-MM-dd').format(previous);
                          //      print(previousDate);
                          if (widget.predictAgain) {
                            makeForecast();
                          } else {
                            result = USER.prediction.toString();
                          }

                          return Container(
                            width: w * 0.7,
                            height: h * 0.4,
                            child: Column(
                              //  mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Center(
                                  child: Center(
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Color.fromARGB(255, 12, 12, 12),
                                      radius: 155,
                                      // child:
                                      child: Text(" LOADING DATA"),
                                    ), //CircleAvatar
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text("Something is Wrong");
                        }
                      }),
                  SizedBox(
                    height: h * 0.10,
                    width: w,
                  ),
                  SizedBox(
                    height: h * 0.06,
                    width: w,
                  ),
                  FutureBuilder<RetrieveData?>(
                      future: retrieveUSERData(widget.email!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final USER = snapshot.data!;
                          return Container(
                            width: w * 0.7,
                            height: h * 0.2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'महिनावारीको मिति परिवर्तन गर्न',
                                  style: GoogleFonts.getFont(
                                    'Khand',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 5, 5, 5),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.03,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(39, 3, 27, 0.686),
                                  ),
                                  onPressed: () async {
                                    // RetrieveData? x =
                                    //     await retrieveUSERData(widget.email!);
                                    // print(x?.age);

                                    //String Datevalues = retrievePeriodDates(widget.email).toString();
                                    // final String periodDate =
                                    //     await retrievePeriodDates2(widget.email);
                                    final String periodDate =
                                        await retrievePeriodDates2(
                                            widget.email);
                                    uilength(widget.email);
                                    // print(periodDate);
                                    _showdatepicker(periodDate);
                                    // print(periodDate);
                                    //_showdatepicker(periodDate);
                                    //retrievePeriodDates(widget.email);
                                  },
                                  child: Center(
                                    child: Text(
                                      "मिति छान्नु होस्",
                                      style: GoogleFonts.getFont(
                                        'Khand',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 253, 250, 250),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text("Loading Data");
                        }
                      }),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor:
              Color.fromARGB(255, 66, 13, 106), // set background color
          type: BottomNavigationBarType.fixed, // set type to fixed
          selectedItemColor: Colors.white, // set selected item color
          unselectedItemColor: Colors.grey[400], // set unselected item color
          iconSize: 30, // set icon sizeincrease the size of the icons
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  Get.to(() => MyApps(widget.email));
                },
                child: const Icon(Icons.timer),
              ),
              label: '',
              backgroundColor: const Color.fromARGB(255, 66, 13, 106),
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  Get.to(() => Calendar(widget.email));
                },
                child: const Icon(Icons.calendar_month),
              ),
              label: '',
              backgroundColor: const Color.fromARGB(255, 66, 13, 106),
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  Get.to(() => MyHomePage(widget.email));
                },
                child: const Icon(Icons.girl_sharp),
              ),
              label: '',
              backgroundColor: const Color.fromARGB(255, 66, 13, 106),
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  Get.to(() => Stat(widget.email));
                },
                child: const Icon(Icons.auto_graph),
              ),
              label: '',
              backgroundColor: const Color.fromARGB(255, 66, 13, 106),
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  Get.to(() => Content(widget.email));
                },
                child: const Icon(Icons.content_copy),
              ),
              label: '',
              backgroundColor: const Color.fromARGB(255, 66, 13, 106),
            ),
          ],
        ),
      );
    }
  }
}

class USER {
  String? periodDate;
  String? cycleLength;
  String? periodLength;
  int? age;

  USER({
    this.periodDate,
    this.cycleLength,
    this.periodLength,
    this.age,
  });

  Map<String, dynamic> toDetails() {
    return {
      'Age': age,
      'Cycle Length': cycleLength,
      'Period Date': periodDate,
      'Period Length': periodLength,
    };
  }

  static USER fromDatabase(Map<String, dynamic> details) {
    return USER(
        age: details['Age'],
        cycleLength: details['Cycle Length'],
        periodDate: details['Period Date'],
        periodLength: details['Period Length']);
  }
}

Stream<List<USER>> readUSERs() => FirebaseFirestore.instance
    .collection('User Details')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => USER.fromDatabase(doc.data())).toList());

Future<USER?> readUSER(String? email) async {
  final docUSER =
      FirebaseFirestore.instance.collection('User Details').doc(email);
  final snapshot = await docUSER.get();

  if (snapshot.exists) {
    return USER.fromDatabase(snapshot.data()!);
  }
}

Future<int> uilength(String? email) async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DocumentReference<Map<String, dynamic>> documentReference =
      _db.collection('User Details').doc(email);
  final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await documentReference.get();
  if (snapshot.exists) {
    final Map<String, dynamic> data = snapshot.data()!;
    final int prediction = data['Prediction'];
    final String periodDate = await retrievePeriodDates2(email);
    NepaliDateTime periodDates = NepaliDateTime.parse(periodDate);
    periodDates = periodDates.add(Duration(days: prediction));
    NepaliDateTime now = NepaliDateTime.now();
    String nows = '${now.year}-${now.month}-${now.day}';
    NepaliDateTime now2 = NepaliDateTime.parse(nows);
    int difference = periodDates.difference(now2).inDays;
    //int differenceInDays = (periodDates.compareTo(now));
    //difference = difference * differenceInDays;
    //print(difference);
    return difference;
  }
  return 0;
}

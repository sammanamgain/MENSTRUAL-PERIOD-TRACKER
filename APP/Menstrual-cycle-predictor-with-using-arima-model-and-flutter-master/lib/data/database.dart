import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menstrual_period_tracker/input/input3.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

void addPeriodDate(String? userId, String formattedDate) {
  // Get the current date in the Nepali calendar
  //NepaliDateTime now = NepaliDateTime.now();
  // String formattedDate = '${now.year}-${now.month}-${now.day}';
  NepaliDateTime now = NepaliDateTime.now();
  String dateString = '${now.year}-${now.month}-${now.day}';
  // Create a map with the timestamp and cycle length
  Map<String, dynamic> periodDate = {
    "Period Date": {
      dateString: formattedDate,
    },
  };

  // Add the cycle data to Firestore
  FirebaseFirestore.instance
      .collection('User Details')
      .doc(userId)
      .set(periodDate, SetOptions(merge: true));
}

Future<String> retrievePeriodDates2(String? email) async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DocumentReference<Map<String, dynamic>> documentReference =
      _db.collection('User Details').doc(email);
  final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await documentReference.get();

  final Map<String, String> periodDate = {};
  if (snapshot.exists) {
    final Map<String, dynamic> data = snapshot.data()!;
    final Map<String, dynamic> periodDateData = data['Period Date'];
    periodDateData.forEach((key, value) {
      periodDate[key] = value as String;
    });
    List<String> date = periodDate.values.toList();
    print(date.last);
    return date.last;
  }

  return '';
}

Future<String> retrievePeriodLength(String? email) async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DocumentReference<Map<String, dynamic>> documentReference =
      _db.collection('User Details').doc(email);
  final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await documentReference.get();

  final Map<String, String> periodDate = {};
  if (snapshot.exists) {
    final Map<String, dynamic> data = snapshot.data()!;
    final Map<String, dynamic> periodDateData = data['predictedlength'];
    periodDateData.forEach((key, value) {
      periodDate[key] = value as String;
    });
    List<String> date = periodDate.values.toList();
    // print(date[0]);
    return date[0];
  }

  return '';
}

Future<List<String>> retrievePeriodDates(String? email) async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DocumentReference<Map<String, dynamic>> documentReference =
      _db.collection('User Details').doc(email);
  final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await documentReference.get();

  final Map<String, String> periodDate = {};
  if (snapshot.exists) {
    final Map<String, dynamic> data = snapshot.data()!;
    final Map<String, dynamic> periodDateData = data['perioddate'];
    periodDateData.forEach((key, value) {
      periodDate[key] = value as String;
    });
    List<String> dates = periodDate.values.toList();
    print(dates);
    return dates;
  }
  List<String> a = ['a', 'b'];
  return a;
}

// To ckeck multiple dates without changing date of mobile
void addPeriodDate2(String? userId, String formattedDate) {
  // Get the current date in the Nepali calendar
  //NepaliDateTime now = NepaliDateTime.now();
  // String formattedDate = '${now.year}-${now.month}-${now.day}';
  //NepaliDateTime now =NepaliDateTime.now();
  String dateString = '2079-11-15';
  // Create a map with the timestamp and cycle length
  Map<String, dynamic> periodDate = {
    "Period Date": {
      dateString: formattedDate,
    },
  };

  // Add the cycle data to Firestore
  FirebaseFirestore.instance
      .collection('User Details')
      .doc(userId)
      .set(periodDate, SetOptions(merge: true));
}

Future<String> retrieveCycleLength(String? email) async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DocumentReference<Map<String, dynamic>> documentReference =
      _db.collection('User Details').doc(email);
  final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await documentReference.get();

  final Map<String, String> periodDate = {};
  if (snapshot.exists) {
    final Map<String, dynamic> data = snapshot.data()!;
    final Map<String, dynamic> cyccleLengthData = data['cycke length'];
    cyccleLengthData.forEach((key, value) {
      periodDate[key] = value as String;
    });
    List<String> date = periodDate.values.toList();
    //print(date);
    return date[0];
  }

  return '';
}

class RetrieveData {
  int? age;
  List<int>? cycleLength;
  // int? cycle;
  String? periodDate;
  int? prediction;
  RetrieveData(this.age, this.cycleLength, this.periodDate, this.prediction);
}

Future<RetrieveData?> retrieveUSERData(String email) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DocumentReference<Map<String, dynamic>> documentReference =
      firestore.collection('User Details').doc(email);
  final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await documentReference.get();
  print("before if condition");
  if (snapshot.exists) {
    print("entered in the snapshot");
    final Map<String, dynamic> data = snapshot.data()!;
    final int age = data['Age'];
    print(age);
    final int prediction = data['Prediction'];
    // List<int>? cycleLength;
    // if (data['cycle length'] is List) {
    //   cycleLength = List<int>.from(data['cycle length']);
    //   print(cycleLength); // Retrieve cycleLength as List<int>
    // } else {
    //   cycleLength = [double.parse(data['cycle length']).round()];
    //   print(cycleLength); // Fallback to parsing the double value
    // }

    final Map<String, int> cyclelength = {};

    final Map<String, dynamic> cycleLengthMap = data['cycle length'];

    cycleLengthMap.forEach((key, value) {
      cyclelength[key] = value;
    });
    print("ss3");

    //final List<int> cycleLength = List<int>.from(data['cycle length']);
    final List<int> cycleLength = cyclelength.values.toList();
    print("ss");
    print(cycleLength);

    // final int cycle = double.parse(data['cycle length']).round();
    final Map<String, dynamic> periodDateMap = data['Period Date'];
    final String periodDate = periodDateMap.values.toList().last.toString();
    return RetrieveData(age, cycleLength, periodDate, prediction);
  } else {
    return null;
  }
}


//ret("sss");
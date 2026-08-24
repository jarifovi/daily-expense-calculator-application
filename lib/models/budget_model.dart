//firestore_library is used to store data in cloud_firestore database.

import 'package:cloud_firestore/cloud_firestore.dart';

//class budget model is used to store the data in the budget collection in the cloud_firestore database.
class Budget { 
  //These variables define what a "Budget" is in our system:
  final String id; 
  final String userId;
  final String month; // e.g., "July"
  final int year; // e.g., 2026
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

//Constructor to create a new Budget object parameterized constructor
  Budget({
    required this.id,
    this.userId = '',
    required this.month,
    required this.year,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  // Unique key for month+year
  String get monthYearKey => '$month $year';

  //Convert from Firestore document
  factory Budget.fromFirestore(DocumentSnapshot doc) { //
    final data = doc.data() as Map<String, dynamic>; //document snapshot.data() returns the data from the document.It is a map of strings to dynamic objects.
    final createdAtTimestamp = (data['createdAt'] ?? data['createAt']) as Timestamp?;
    final updatedAtTimestamp = (data['updatedAt'] ?? data['updateAt']) as Timestamp?;
    
    return Budget( //Creating a new Budget object from the data.
      id: doc.id, //document id
      userId: data['userId'] ?? '',
      month: data['month'] ?? '', //month
      year: data['year'] ?? DateTime.now().year,//year
      amount: (data['amount'] ?? 0).toDouble(),//amount
      createdAt: createdAtTimestamp?.toDate() ?? DateTime.now(),//created at
      updatedAt: updatedAtTimestamp?.toDate() ?? DateTime.now(),//updated at
    );
  } //Returning a new Budget object from the data.

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() { //Converting a Budget object to a map.
    return {
      'userId': userId,
      'month': month,
      'year': year,
      'amount': amount,
      //Timestamp is used to store the date and time in Firestore.
      'createdAt': Timestamp.fromDate(createdAt), //Timestamp is used to store the date and time in Firestore.
      'updatedAt': Timestamp.fromDate(updatedAt), //Timestamp is used to store the date and time in Firestore.
    };
  } //Returning a map of the Budget object.

  //Copy with
  Budget copyWith({ //Creating a new Budget object from the data.
    String? id,
    String? userId,
    String? month,
    int? year,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget( //Creating a new Budget object from the data.
      id: id ?? this.id, //document id
      userId: userId ?? this.userId,
      month: month ?? this.month, //month
      year: year ?? this.year, //year
      amount: amount ?? this.amount, //amount
      createdAt: createdAt ?? this.createdAt, //created at
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

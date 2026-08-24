import 'package:cloud_firestore/cloud_firestore.dart';
//class expense model is used to store the data in the expense collection in the cloud_firestore database.
class Expense {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final DateTime createdAt;
//parameterized constructor
  Expense({
    required this.id,
    this.userId = '',
    required this.name,
    required this.amount,
    required this.category,
    this.description = '',
    required this.date,
    required this.createdAt,
  });

  // Convert from Firestore document
  factory Expense.fromFirestore(DocumentSnapshot doc) { //Converting a Firestore document to an Expense object.
    final data = doc.data() as Map<String, dynamic>;
    final dateTimestamp = data['date'] as Timestamp?;
    final createdAtTimestamp = (data['createdAt'] ?? data['createAt']) as Timestamp?;
    
    return Expense(
      id: doc.id, //document id
      userId: data['userId'] ?? '',
      name: data['name'] ?? '', //name
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Other', //category
      description: data['description'] ?? data['notes'] ?? '', //description
      date: dateTimestamp?.toDate() ?? DateTime.now(), //date
      createdAt: createdAtTimestamp?.toDate() ?? DateTime.now(), //created at
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() { //Converting an Expense object to a map.
    return {
      'userId': userId,
      'name': name, //name
      'amount': amount, //amount
      'category': category, //category
      'description': description, //description
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with
  Expense copyWith({ //Creating a new Expense object from the data. 
    String? id, //document id
    String? userId,
    String? name, //name
    double? amount, //amount
    String? category, //category
    String? description, //description
    DateTime? date, //date
    DateTime? createdAt, //created at
  }) {
    return Expense(
      id: id ?? this.id, //document id
      userId: userId ?? this.userId,
      name: name ?? this.name, //name
      amount: amount ?? this.amount, //amount
      category: category ?? this.category, //category
      description: description ?? this.description, //description
      date: date ?? this.date, //date
      createdAt: createdAt ?? this.createdAt, //created at
    );
  }
}

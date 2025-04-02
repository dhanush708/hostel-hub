import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HostelHubApp());
}

class HostelHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InitialPage(),
    );
  }
}

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      if (username == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard(username: username)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == 'dhanush.vijayasri@kce.com' && password == 'karpagam') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', 'admin');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDashboard(username: username)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text('Login'),
            ),
            SizedBox(height: 40),
            Text(
              'Made by Dhanush',
              style:TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isMealCounterOn = false;
  int totalOrders = 0;

  void toggleMealCounter() async {
    isMealCounterOn = !isMealCounterOn;
    await FirebaseFirestore.instance.collection('mealCounter').doc('status').set({
      'isMealCounterOn': isMealCounterOn,
      'totalOrders': isMealCounterOn ? totalOrders : 0
    });
    setState(() {});
  }

  void resetMealCounter() async {
    await FirebaseFirestore.instance.collection('mealCounter').doc('status').update({
      'totalOrders': 0
    });
    setState(() {
      totalOrders = 0;
    });
  }

  void resetComplaints() async {
    var complaints = await FirebaseFirestore.instance.collection('complaints').get();
    for (var doc in complaints.docs) {
      await doc.reference.delete();
    }
  }

  void resetLostAndFound() async {
    var items = await FirebaseFirestore.instance.collection('lostAndFound').get();
    for (var doc in items.docs) {
      await doc.reference.delete();
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('mealCounter').doc('status').snapshots().listen((doc) {
      if (doc.exists) {
        setState(() {
          isMealCounterOn = doc['isMealCounterOn'];
          totalOrders = doc['totalOrders'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard'), actions: [
        IconButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('username');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          icon: Icon(Icons.logout),
        ),
      ]),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: toggleMealCounter,
            child: Text(isMealCounterOn ? 'Close Meal Counter' : 'Open Meal Counter'),
          ),
          Text('Total Meals Ordered: $totalOrders'),
          ElevatedButton(
            onPressed: resetMealCounter,
            child: Text('Reset Meal Counter'),
          ),
          ElevatedButton(
            onPressed: resetComplaints,
            child: Text('Reset Complaints'),
          ),
          ElevatedButton(
            onPressed: resetLostAndFound,
            child: Text('Reset Lost & Found'),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return ExpansionTile(
                title: Text('View Complaints'),
                children: snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc['username']),
                    subtitle: Text(doc['complaint']),
                  );
                }).toList(),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('lostAndFound').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return ExpansionTile(
                title: Text('View Lost & Found Items'),
                children: snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc['itemName']),
                    subtitle: Text('Reported by: ${doc['username']}\nPlace: ${doc['place']}, Date: ${doc['date']}, Time: ${doc['time']}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UserDashboard extends StatefulWidget {
  final String username;
  UserDashboard({required this.username});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool isMealCounterOn = false;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('mealCounter').doc('status').snapshots().listen((doc) {
      if (doc.exists) {
        setState(() {
          isMealCounterOn = doc['isMealCounterOn'];
        });
      }
    });
  }

  void confirmMeal() async {
    if (isMealCounterOn) {
      await FirebaseFirestore.instance.collection('mealCounter').doc('status').update({
        'totalOrders': FieldValue.increment(1)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meal Added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The counter is closed')),
      );
    }
  }

  void submitComplaint(String complaint) async {
    await FirebaseFirestore.instance.collection('complaints').add({
      'username': widget.username,
      'complaint': complaint
    });
  }

  void submitLostItem(String itemName, String place, String date, String time) async {
    await FirebaseFirestore.instance.collection('lostAndFound').add({
      'username': widget.username,
      'itemName': itemName,
      'place': place,
      'date': date,
      'time': time
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Dashboard'), actions: [
        IconButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('username');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          icon: Icon(Icons.logout),
        ),
      ]),
      body: ListView(
        children: [
          isMealCounterOn
              ? ElevatedButton(
            onPressed: confirmMeal,
            child: Text('Confirm Meal for Today'),
          )
              : Text('Meal registration is currently closed.'),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController complaintController = TextEditingController();
                  return AlertDialog(
                    title: Text('Submit Complaint'),
                    content: TextField(
                      controller: complaintController,
                      decoration: InputDecoration(hintText: 'Enter your complaint'),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          submitComplaint(complaintController.text);
                          Navigator.pop(context);
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Submit Complaint'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController itemNameController = TextEditingController();
                  TextEditingController placeController = TextEditingController();
                  TextEditingController dateController = TextEditingController();
                  TextEditingController timeController = TextEditingController();
                  return AlertDialog(
                    title: Text('Report Lost Item'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: itemNameController,
                          decoration: InputDecoration(hintText: 'Item Name'),
                        ),
                        TextField(
                          controller: placeController,
                          decoration: InputDecoration(hintText: 'Last Seen Place'),
                        ),
                        TextField(
                          controller: dateController,
                          decoration: InputDecoration(hintText: 'Date'),
                        ),
                        TextField(
                          controller: timeController,
                          decoration: InputDecoration(hintText: 'Time'),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          submitLostItem(
                              itemNameController.text,
                              placeController.text,
                              dateController.text,
                              timeController.text
                          );
                          Navigator.pop(context);
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Report Lost Item'),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('lostAndFound').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return ExpansionTile(
                title: Text('View Lost & Found Items'),
                children: snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc['itemName']),
                    subtitle: Text('Reported by: ${doc['username']}\nPlace: ${doc['place']}, Date: ${doc['date']}, Time: ${doc['time']}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
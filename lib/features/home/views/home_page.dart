import 'package:flutter/material.dart';
import '../../../services/remote/firestore_service.dart';
import 'package:proj_management_project/config/di/injection_container.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirestoreService _firestoreService = sl<FirestoreService>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _completeTask() async {
    await _firestoreService.updateStreak(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _completeTask,
              child: const Text('Complete Task'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/NextPage');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

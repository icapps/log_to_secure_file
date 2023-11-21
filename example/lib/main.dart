import 'package:flutter/material.dart';
import 'package:log_to_secure_file/log_to_secure_file.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final SecureLogStorage logStorage = SecureLogStorage();
  int _count = 0;

  void _onAddLogTapped() {
    logStorage.storeLogLine('Button pressed $_count times');
    setState(() {
      _count += 1;
    });
  }

  Future<void> _onDeleteLogsTapped() async {
    await logStorage.deleteLogs();
    setState(() {});
  }

  Future<void> _onReadLogTapped(BuildContext context) {
    return logStorage.getLogFromDate(DateTime.now()).then(
          (logs) => showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: logs.map((log) => Text(log)).toList()),
                ),
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MaterialButton(
                  onPressed: _onAddLogTapped,
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text('Add Log'),
                ),
                MaterialButton(
                  onPressed: () => _onReadLogTapped(context),
                  color: Colors.yellow,
                  textColor: Colors.black,
                  child: const Text('Read Log'),
                ),
                MaterialButton(
                  onPressed: _onDeleteLogsTapped,
                  color: Colors.red,
                  textColor: Colors.white,
                  child: const Text('Delete Logs'),
                ),
                FutureBuilder<List<DateTime>>(
                  future: logStorage.availableDates(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: snapshot.data!.map((date) => Text(date.toString())).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

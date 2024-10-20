import 'package:digi_forensic/services/files.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Import for Timer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenshotHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScreenshotHome extends StatefulWidget {
  @override
  _ScreenshotHomeState createState() => _ScreenshotHomeState();
}

class _ScreenshotHomeState extends State<ScreenshotHome> {
  static const platform = MethodChannel('screenshot_channel');
  Timer? _timer; // Declare a Timer variable
  String selectedReport = 'Day 1'; // To keep track of selected report
  ReportFetcher reportFetcher = ReportFetcher();
  Map<String, Map<String, dynamic>> reports = {}; // Initialize the reports variable
  // ignore: non_constant_identifier_names
  bool fetched_reports = false;

  List<String> daysOfWeek = [];

  Future<void> _fetchReports() async {
    try {
      reports = await reportFetcher.getReports(); // Fetch reports asynchronously
      setState(() {
        // Update the state to reflect the fetched reports
        daysOfWeek = reports.keys.toList();
        fetched_reports = true;
        if (daysOfWeek.isNotEmpty) {
          selectedReport = daysOfWeek[0];
        }
      });
    } catch (e) {
      print('Error fetching reports: $e');
    }
  }

  @override
  void initState() {
    _fetchReports(); // Call the function to fetch reports
    super.initState();
    // Start the periodic timer to take screenshots every 1 minute
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      takeScreenshot();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> takeScreenshot() async {
    try {
      final result = await platform.invokeMethod('takeScreenshot');
      print('Screenshot saved at: $result');
    } on PlatformException catch (e) {
      print("Failed to take screenshot: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Forensic')),
      body: !fetched_reports ? Center(child: const Text("Fetching your reports")): Row(
        children: [
          // Left Sidebar
          Container(
            width: 200,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(daysOfWeek[index]),
                  selected: selectedReport == daysOfWeek[index],
                  onTap: () {
                    setState(() {
                      selectedReport = daysOfWeek[index];
                    });
                  },
                );
              },
            ),
          ),
          // Right Report Display
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildReportContent(reports[selectedReport]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the report content
  Widget buildReportContent(Map<String, dynamic>? report) {
    if (report == null) {
      return const Center(child: Text('No report available.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content Analysis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(report["content_analysis"]["summary"]),
        const SizedBox(height: 20),
        const Text(
          'Problematic Usage Patterns',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...report["problematic_usage_patterns"]["issues"]
            .map<Widget>((issue) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue["issue"],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(issue["description"]),
                    SizedBox(height: 15),
                  ],
                ))
            .toList(),
        const SizedBox(height: 20),
        const Text(
          'Positive Usage Patterns',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...report["positive_usage"]["patterns"]
            .map<Widget>((issue) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue["pattern"],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(issue["description"]),
                    SizedBox(height: 15),
                  ],
                ))
            .toList(),

        const Text(
          'Recommendations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...report["recommendations"]["suggestions"]
            .map<Widget>((issue) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue["recommendation"],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(issue["details"]),
                    SizedBox(height: 15),
                  ],
                ))
            .toList(),
      ],
    );
  }
}

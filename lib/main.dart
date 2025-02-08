import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String appWidgetProviderClass = 'HomeScreenWidgetProvider';
const String countKey = 'counter';
const String backgroundUpdate = "backgroundUpdate";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(const MyApp());
}

Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == backgroundUpdate) {
    int? counter = await HomeWidget.getWidgetData<int>(countKey, defaultValue: 0);
    counter = counter! + 1;
    
    // Update both storage locations
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(countKey, counter);
    await HomeWidget.saveWidgetData<int>(countKey, counter);
    
    await HomeWidget.updateWidget(
      name: appWidgetProviderClass,
      androidName: 'HomeScreenWidgetProvider',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Home Widget Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Home Widget Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _setupHomeWidget();
  }

  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int? storedCounter = prefs.getInt(countKey);
    
    if (storedCounter == null) {
      storedCounter = await HomeWidget.getWidgetData<int>(countKey, defaultValue: 0);
      if (storedCounter != null) {
        await prefs.setInt(countKey, storedCounter);
      }
    }
    
    setState(() {
      _counter = storedCounter ?? 0;
    });
  }

  Future<void> _setupHomeWidget() async {
    await HomeWidget.setAppGroupId('com.example.home_widget');
  }

  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
    });

    await prefs.setInt(countKey, _counter);
    await HomeWidget.saveWidgetData<int>(countKey, _counter);
    
    await HomeWidget.updateWidget(
      name: appWidgetProviderClass,
      androidName: 'HomeScreenWidgetProvider',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
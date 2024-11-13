import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'bloc/data_usage_bloc.dart';
import 'models/data_usage.dart';
import 'ui/home_screen.dart';

final StreamController<ConnectivityResult> _connectivityStreamController = StreamController<ConnectivityResult>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(DataUsageAdapter());

  runApp(MyApp());
  simulateNetworkChange();
}

void simulateNetworkChange() {
  _connectivityStreamController.add(ConnectivityResult.mobile);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cellular Data Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => DataUsageBloc(connectivityStream: _connectivityStreamController.stream),
        child: const HomeScreen(),
      ),
    );
  }
}

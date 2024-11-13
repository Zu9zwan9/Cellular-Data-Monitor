import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/data_usage.dart';
import '../services/ai_service.dart';

part 'data_usage_event.dart';
part 'data_usage_state.dart';

class DataUsageBloc extends Bloc<DataUsageEvent, DataUsageState> {
  final Stream<ConnectivityResult> connectivityStream;
  StreamSubscription<ConnectivityResult>? _subscription;
  late Box<DataUsage> _box;
  final AIService _aiService = AIService();
  Timer? _monitoringTimer;
  ConnectivityResult? _selectedNetworkType;

  DataUsageBloc({required this.connectivityStream}) : super(DataUsageInitial()) {
    on<DataUsageStarted>(_onDataUsageStarted);
    on<DataUsageStopped>(_onDataUsageStopped);
    on<SetMonitoringPeriod>(_onSetMonitoringPeriod);
    on<SelectNetworkType>(_onSelectNetworkType);

    _initializeHive();
  }

  Future<void> _initializeHive() async {
    final directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);
    _box = await Hive.openBox('data_usages');
  }

  void _onDataUsageStarted(
      DataUsageStarted event,
      Emitter<DataUsageState> emit,
      ) async {
    emit(DataUsageLoading());

    try {
      _subscription = connectivityStream.listen((result) {
        if (result == _selectedNetworkType) {
          // Simulate data usage tracking
          final usage = DataUsage(
            usage: _selectedNetworkType == ConnectivityResult.mobile
                ? 10.0 * (DateTime.now().millisecondsSinceEpoch % 100) / 1000 // Simulate increasing usage
                : 5.0 * (DateTime.now().millisecondsSinceEpoch % 100) / 1000, // Simulate increasing usage
            timestamp: DateTime.now(),
          );
          _box.add(usage);
        }
      });

      final dataUsages = _box.values.toList();
      final now = DateTime.now();
      final usage1Day = dataUsages
          .where((du) => du.timestamp.isAfter(now.subtract(Duration(days: 1))))
          .fold(0.0, (sum, du) => sum + du.usage);
      final usage3Days = dataUsages
          .where((du) => du.timestamp.isAfter(now.subtract(Duration(days: 3))))
          .fold(0.0, (sum, du) => sum + du.usage);
      final usage1Week = dataUsages
          .where((du) => du.timestamp.isAfter(now.subtract(Duration(days: 7))))
          .fold(0.0, (sum, du) => sum + du.usage);
      final usage1Month = dataUsages
          .where((du) => du.timestamp.isAfter(now.subtract(Duration(days: 30))))
          .fold(0.0, (sum, du) => sum + du.usage);

      final insight = await _aiService.analyzeData(
        dataUsages.map((du) => {'timestamp': du.timestamp.toIso8601String(), 'usage': du.usage}).toList(),
      );

      emit(DataUsageLoaded(
        dataUsages: dataUsages,
        usage1Day: usage1Day,
        usage3Days: usage3Days,
        usage1Week: usage1Week,
        usage1Month: usage1Month,
        insight: insight,
      ));
    } catch (e) {
      emit(DataUsageError(message: e.toString()));
    }
  }

  void _onDataUsageStopped(
      DataUsageStopped event,
      Emitter<DataUsageState> emit,
      ) async {
    _subscription?.cancel();
    _monitoringTimer?.cancel();
    final dataUsages = _box.values.toList();
    if (dataUsages.isNotEmpty) {
      try {
        final now = DateTime.now();
        final usage1Day = dataUsages
            .where((du) => du.timestamp.isAfter(now.subtract(Duration(days: 1))))
            .fold(0.0, (sum, du) => sum + du.usage);
        final usage3Days = dataUsages
            .where((du) => du.timestamp.isAfter(now.subtract(Duration(days: 3))))
            .fold(0.0, (sum, du) => sum + du.usage);
        final usage1Week = dataUsages
            .where((du) => du.timestamp.isAfter(now.subtract(Duration(days: 7))))
            .fold(0.0, (sum, du) => sum + du.usage);
        final usage1Month = dataUsages
            .where((du) => du.timestamp.isAfter(now.subtract(Duration(days: 30))))
            .fold(0.0, (sum, du) => sum + du.usage);

        final insight = await _aiService.analyzeData(
          dataUsages.map((du) => {'timestamp': du.timestamp.toIso8601String(), 'usage': du.usage}).toList(),
        );
        emit(DataUsageLoaded(
          dataUsages: dataUsages,
          insight: insight,
          usage1Day: usage1Day,
          usage3Days: usage3Days,
          usage1Week: usage1Week,
          usage1Month: usage1Month,
        ));
      } catch (e) {
        print('Error: ${e.toString()}');
        emit(DataUsageError(message: 'Failed to load insight: ${e.toString()}'));
      }
    } else {
      emit(DataUsageInitial());
    }
  }

  void _onSetMonitoringPeriod(
      SetMonitoringPeriod event,
      Emitter<DataUsageState> emit,
      ) async {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(event.period, (timer) {
      add(DataUsageStarted());
    });
  }

  void _onSelectNetworkType(
      SelectNetworkType event,
      Emitter<DataUsageState> emit,
      ) {
    _selectedNetworkType = event.networkType;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _monitoringTimer?.cancel();
    return super.close();
  }
}

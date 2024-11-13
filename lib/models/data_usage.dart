import 'package:hive/hive.dart';

part 'data_usage.g.dart';

@HiveType(typeId: 0)
class DataUsage extends HiveObject {
  @HiveField(0)
  final double usage;

  @HiveField(1)
  final DateTime timestamp;

  DataUsage({required this.usage, required this.timestamp});
}

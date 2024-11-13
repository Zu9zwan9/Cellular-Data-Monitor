part of 'data_usage_bloc.dart';

abstract class DataUsageState extends Equatable {
  const DataUsageState();

  @override
  List<Object> get props => [];
}

class DataUsageInitial extends DataUsageState {}

class DataUsageLoading extends DataUsageState {}

class DataUsageLoaded extends DataUsageState {
  final List<DataUsage> dataUsages;
  final String insight;
  final double usage1Day;
  final double usage3Days;
  final double usage1Week;
  final double usage1Month;

  const DataUsageLoaded({
    required this.dataUsages,
    this.insight = '',
    required this.usage1Day,
    required this.usage3Days,
    required this.usage1Week,
    required this.usage1Month,
  });

  @override
  List<Object> get props => [dataUsages, insight, usage1Day, usage3Days, usage1Week, usage1Month];
}

class DataUsageError extends DataUsageState {
  final String message;

  const DataUsageError({required this.message});

  @override
  List<Object> get props => [message];
}

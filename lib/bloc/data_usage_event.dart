part of 'data_usage_bloc.dart';

abstract class DataUsageEvent extends Equatable {
  const DataUsageEvent();

  @override
  List<Object> get props => [];
}

class DataUsageStarted extends DataUsageEvent {}

class DataUsageStopped extends DataUsageEvent {}

class SetMonitoringPeriod extends DataUsageEvent {
  final Duration period;

  const SetMonitoringPeriod(this.period);

  @override
  List<Object> get props => [period];
}

class SelectNetworkType extends DataUsageEvent {
  final ConnectivityResult networkType;

  const SelectNetworkType(this.networkType);

  @override
  List<Object> get props => [networkType];
}

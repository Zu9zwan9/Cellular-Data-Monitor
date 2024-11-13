import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../bloc/data_usage_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Usage Monitor'),
      ),
      body: Center(
        child: BlocBuilder<DataUsageBloc, DataUsageState>(
          builder: (context, state) {
            if (state is DataUsageInitial) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<DataUsageBloc>().add(DataUsageStarted());
                      },
                      child: const Text('Monitor Cellular'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DataUsageBloc>().add(const SelectNetworkType(ConnectivityResult.wifi));
                        context.read<DataUsageBloc>().add(DataUsageStarted());
                      },
                      child: const Text('Monitor WiFi'),
                    ),
                  ],
                ),
              );
            } else if (state is DataUsageLoading) {
              return const CircularProgressIndicator();
            } else if (state is DataUsageLoaded) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                    return Text(
                                      '${date.day}/${date.month}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.black, width: 1),
                                bottom: BorderSide(color: Colors.black, width: 1),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: state.dataUsages
                                    .map((data) => FlSpot(
                                  data.timestamp.millisecondsSinceEpoch.toDouble(),
                                  data.usage,
                                ))
                                    .toList(),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 2,
                                belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Insight: ${state.insight}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('Usage in 1 day: ${state.usage1Day.toStringAsFixed(2)} GB'),
                          Text('Usage in 3 days: ${state.usage3Days.toStringAsFixed(2)} GB'),
                          Text('Usage in 1 week: ${state.usage1Week.toStringAsFixed(2)} GB'),
                          Text('Usage in 1 month: ${state.usage1Month.toStringAsFixed(2)} GB'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => context.read<DataUsageBloc>().add(DataUsageStopped()),
                      child: const Text('Stop Monitoring'),
                    ),
                  ],
                ),
              );
            } else if (state is DataUsageError) {
              return Text('Error: ${state.message}');
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

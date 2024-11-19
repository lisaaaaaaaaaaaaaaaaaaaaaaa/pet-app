import 'package:flutter/material.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Stats Overview'),
      ),
    );
  }
}

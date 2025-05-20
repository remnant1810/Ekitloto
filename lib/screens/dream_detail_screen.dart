import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../main.dart';
import '_dream_detail_body.dart';
import '_dream_detail_body.dart' show _DreamDetailBodyState;

final GlobalKey _dreamDetailBodyKey = GlobalKey();

class DreamDetailScreen extends StatelessWidget {
  final Dream dream;

  const DreamDetailScreen({Key? key, required this.dream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Details'),
        actions: const [
          // Save button removed from AppBar as requested
        ],
      ),
      body: DreamDetailBody(key: _dreamDetailBodyKey, dream: dream),
    );
  }
}

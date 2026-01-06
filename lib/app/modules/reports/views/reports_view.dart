import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReportsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ReportsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

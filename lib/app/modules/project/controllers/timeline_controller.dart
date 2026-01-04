// lib/app/modules/project/controllers/timeline_controller.dart
import 'package:get/get.dart';

class TimelineItem {
  final String message;
  final DateTime time;

  TimelineItem(this.message, this.time);
}

class TimelineController extends GetxController {
  final items = <TimelineItem>[].obs;

  get activities => null;

  void add(String msg) {
    items.insert(
      0,
      TimelineItem(msg, DateTime.now()),
    );
  }
}

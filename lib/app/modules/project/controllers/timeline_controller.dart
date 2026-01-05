import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/project_item.dart';
import 'package:project_tracking/app/data/service/project_service.dart';

class TimelineController extends GetxController {
  final int projectId;
  TimelineController(this.projectId);

  final ProjectService _service = ProjectService();
  
  var isLoading = false.obs;
  var activities = <ActivityItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTimeline();
  }

  Future<void> fetchTimeline() async {
    try {
      isLoading.value = true;
      // Panggil API getDetail yang baru kita update di Laravel
      final data = await _service.getProjectDetail(projectId);
      
      if (data['activities'] != null) {
        final List list = data['activities'];
        activities.assignAll(list.map((e) => ActivityItem.fromJson(e)).toList());
      }
    } catch (e) {
      print("Error fetch timeline: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
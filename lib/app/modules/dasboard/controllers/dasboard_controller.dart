import 'package:get/get.dart';
import 'package:project_tracking/app/routes/app_pages.dart';
import '../../../data/service/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();

  // Reactive Variables untuk UI
  var isLoading = true.obs;
  var userName = 'Pengguna'.obs; // Default sebelum load
  
  // Statistik (Default 0)
  var totalProject = 0.obs;
  var totalInProgress = 0.obs;
  var totalReview = 0.obs;
  var totalDone = 0.obs;
  var totalTodo = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    
    final result = await _service.getDashboardStats();

    if (result['success']) {
      final data = result['data'];
      final user = data['user'];
      final stats = data['stats'];

      // Update User Name
      userName.value = user['name'] ?? 'Pengguna';

      // Update Statistik
      totalProject.value = stats['total_project'] ?? 0;
      totalInProgress.value = stats['total_in_progress'] ?? 0;
      totalReview.value = stats['total_review'] ?? 0;
      totalDone.value = stats['total_done'] ?? 0;
      totalTodo.value = stats['total_todo'] ?? 0; // Kalau mau ditampilkan
    } else {
      // Jika butuh login ulang (401)
      if (result['needLogin'] == true) {
        Get.offAllNamed(Routes.LOGIN); // Lempar ke login
        Get.snackbar('Sesi Habis', 'Silakan login kembali');
      } else {
        // Error biasa (koneksi dll)
        Get.snackbar('Error', result['message']);
      }
    }

    isLoading.value = false;
  }
}
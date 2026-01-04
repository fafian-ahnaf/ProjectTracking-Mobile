import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../data/models/requirement_item.dart';

class PhaseData {
  final RxString notes = ''.obs;           // catatan ringkas fase
  final RxList<String> docs = <String>[].obs; // placeholder nama dokumen
  final RxList<RequirementItem> requirements = <RequirementItem>[].obs; // untuk fase Requirement
}

class PhaseController extends GetxController {
  final List<String> phases;
  final String defaultPic;

  PhaseController({required this.phases, this.defaultPic = ''});

  // Map fase -> data
  final _map = <String, PhaseData>{}.obs;

  PhaseData of(String phase) {
    return _map.putIfAbsent(phase, () => PhaseData());
  }

  // ====== API khusus Requirement ======
  List<RequirementItem> get requirements => of('Requirement').requirements;

  void addRequirement(RequirementItem item) {
    of('Requirement').requirements.add(item);
  }

  void removeRequirementAt(int index) {
    final list = of('Requirement').requirements;
    if (index >= 0 && index < list.length) list.removeAt(index);
  }

  void updateRequirementAt(int index, RequirementItem item) {
    final list = of('Requirement').requirements;
    if (index >= 0 && index < list.length) {
      list[index] = item;
      list.refresh();
    }
  }

  RequirementItem? findRequirementByTitle(String title) {
    return of('Requirement').requirements.firstWhereOrNull((e) => e.title == title);
  }
}

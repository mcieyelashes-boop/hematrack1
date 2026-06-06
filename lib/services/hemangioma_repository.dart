import '../models/follow_up_photo.dart';
import '../models/hemangioma_area.dart';
import 'app_storage.dart';

class HemangiomaRepository {
  HemangiomaRepository._();
  static final HemangiomaRepository instance = HemangiomaRepository._();

  final List<HemangiomaArea> _areas = [];
  final List<FollowUpPhoto> _followUps = [];

  Future<void> load() async {
    final rawAreas = await AppStorage.instance.readJson('areas');
    if (rawAreas is List) {
      _areas.clear();
      _areas.addAll(rawAreas.map((e) => HemangiomaArea.fromJson(e as Map<String, dynamic>)));
    }
    final rawFollowUps = await AppStorage.instance.readJson('followups');
    if (rawFollowUps is List) {
      _followUps.clear();
      _followUps.addAll(rawFollowUps.map((e) => FollowUpPhoto.fromJson(e as Map<String, dynamic>)));
    }
  }

  List<HemangiomaArea> getAreasForChild(String childId) =>
      _areas.where((a) => a.childId == childId).toList();

  HemangiomaArea? findAreaById(String id) {
    try {
      return _areas.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<FollowUpPhoto> getFollowUpsForArea(String areaId) {
    final list = _followUps.where((f) => f.areaId == areaId).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Future<void> addArea(HemangiomaArea area) async {
    _areas.add(area);
    await _saveAreas();
  }

  Future<void> updateAreaBaseline(String areaId, String photoPath) async {
    final idx = _areas.indexWhere((a) => a.id == areaId);
    if (idx == -1) return;
    final old = _areas[idx];
    _areas[idx] = HemangiomaArea(
      id: old.id,
      childId: old.childId,
      bodyLocation: old.bodyLocation,
      baselinePhotoPath: photoPath,
      baselineDate: DateTime.now(),
      baselineAreaValue: old.baselineAreaValue,
      notes: old.notes,
    );
    await _saveAreas();
  }

  Future<void> addFollowUp(FollowUpPhoto photo) async {
    _followUps.add(photo);
    await _saveFollowUps();
  }

  Future<void> deleteArea(String areaId) async {
    _areas.removeWhere((a) => a.id == areaId);
    _followUps.removeWhere((f) => f.areaId == areaId);
    await _saveAreas();
    await _saveFollowUps();
  }

  Future<void> deleteAllAreasForChild(String childId) async {
    final ids = _areas
        .where((a) => a.childId == childId)
        .map((a) => a.id)
        .toSet();
    _areas.removeWhere((a) => a.childId == childId);
    _followUps.removeWhere((f) => ids.contains(f.areaId));
    await _saveAreas();
    await _saveFollowUps();
  }

  Future<void> _saveAreas() async {
    await AppStorage.instance.writeJson(
      'areas',
      _areas.map((a) => a.toJson()).toList(),
    );
  }

  Future<void> _saveFollowUps() async {
    await AppStorage.instance.writeJson(
      'followups',
      _followUps.map((f) => f.toJson()).toList(),
    );
  }
}

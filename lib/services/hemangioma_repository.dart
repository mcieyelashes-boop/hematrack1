import '../models/follow_up_photo.dart';
import '../models/hemangioma_area.dart';

class HemangiomaRepository {
  static final List<HemangiomaArea> _areas = [];
  static final List<FollowUpPhoto> _followUps = [];

  List<HemangiomaArea> getAreas() => _areas;
  List<FollowUpPhoto> getFollowUpsForArea(String areaId) =>
      _followUps.where((item) => item.areaId == areaId).toList();

  void addArea(HemangiomaArea area) {
    _areas.add(area);
  }

  void addFollowUp(FollowUpPhoto photo) {
    _followUps.add(photo);
  }
}

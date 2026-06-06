import '../models/child.dart';
import 'app_storage.dart';

class ChildRepository {
  ChildRepository._();
  static final ChildRepository instance = ChildRepository._();

  final List<Child> _children = [];

  Future<void> load() async {
    final raw = await AppStorage.instance.readJson('children');
    if (raw is List) {
      _children.clear();
      _children.addAll(raw.map((e) => Child.fromJson(e as Map<String, dynamic>)));
    }
  }

  List<Child> getAll() => List.unmodifiable(_children);

  Child? findById(String id) {
    try {
      return _children.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addChild(Child child) async {
    _children.add(child);
    await _save();
  }

  Future<void> _save() async {
    await AppStorage.instance.writeJson(
      'children',
      _children.map((c) => c.toJson()).toList(),
    );
  }
}

import '../models/child.dart';

class ChildRepository {
  static final List<Child> _children = [];

  List<Child> getAll() => _children;

  void addChild(Child child) {
    _children.add(child);
  }
}

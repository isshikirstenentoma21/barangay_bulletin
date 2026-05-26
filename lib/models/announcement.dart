import 'package:hive/hive.dart';

part 'announcement.g.dart';

@HiveType(typeId: 0)
class Announcement extends HiveObject {
  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.datePosted,
    required this.isPinned,
    this.isDeleted = false,
    this.deletedAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String body;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime datePosted;

  @HiveField(5)
  bool isPinned;

  @HiveField(6)
  bool isDeleted;

  @HiveField(7)
  DateTime? deletedAt;

  Announcement copyWith({
    String? title,
    String? body,
    String? category,
    bool? isPinned,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      datePosted: datePosted,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }
}

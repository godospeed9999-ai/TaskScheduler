class BlockedAppModel {
  final int? id;
  final String packageName;
  final String appName;
  final bool isBlocked;

  const BlockedAppModel({
    this.id,
    required this.packageName,
    required this.appName,
    this.isBlocked = false,
  });

  BlockedAppModel copyWith({
    int? id,
    String? packageName,
    String? appName,
    bool? isBlocked,
  }) {
    return BlockedAppModel(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  factory BlockedAppModel.fromMap(Map<String, dynamic> map) {
    return BlockedAppModel(
      id: map['id'] as int?,
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      isBlocked: (map['isBlocked'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'packageName': packageName,
      'appName': appName,
      'isBlocked': isBlocked ? 1 : 0,
    };
  }
}

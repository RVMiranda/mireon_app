class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.createdAt,
    this.isProtected = false,
  });
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final DateTime createdAt;
  final bool isProtected;
}

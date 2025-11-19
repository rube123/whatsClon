class AppUser {
  final String uid;
  final String phoneNumber;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String role; // alumno | profesor
  final String carrera;
  final int semestre;
  final bool isOnline;

  AppUser({
    required this.uid,
    required this.phoneNumber,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.role,
    required this.carrera,
    required this.semestre,
    required this.isOnline,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'phoneNumber': phoneNumber,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'role': role,
    'carrera': carrera,
    'semestre': semestre,
    'isOnline': isOnline,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    uid: map['uid'],
    phoneNumber: map['phoneNumber'] ?? '',
    email: map['email'] ?? '',
    displayName: map['displayName'] ?? '',
    avatarUrl: map['avatarUrl'] ?? '',
    role: map['role'] ?? 'alumno',
    carrera: map['carrera'] ?? '',
    semestre: (map['semestre'] ?? 1) as int,
    isOnline: map['isOnline'] ?? false,
  );
}

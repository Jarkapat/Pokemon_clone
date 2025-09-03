import 'pokemon.dart';

class TeamModel {
  final String id;
  final String name;
  final List<Pokemon> members;

  TeamModel({required this.id, required this.name, required this.members});

  TeamModel copyWith({String? name, List<Pokemon>? members}) =>
      TeamModel(id: id, name: name ?? this.name, members: members ?? this.members);

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'members': members.map((e) => e.toJson()).toList(),
  };

  factory TeamModel.fromJson(Map<String, dynamic> j) => TeamModel(
    id: j['id'], name: j['name'],
    members: (j['members'] as List).map((m) => Pokemon.fromJson(Map<String, dynamic>.from(m))).toList(),
  );
}

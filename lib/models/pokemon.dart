class Stats {
  final int hp, atk, def, spAtk, spDef, speed;
  const Stats({
    required this.hp,
    required this.atk,
    required this.def,
    required this.spAtk,
    required this.spDef,
    required this.speed,
  });

  factory Stats.fromApi(List<dynamic> statsArr) {
    int v(String k) {
      final m = statsArr.firstWhere((e) => e['stat']['name'] == k) as Map<String, dynamic>;
      return m['base_stat'] as int;
    }
    return Stats(
      hp: v('hp'),
      atk: v('attack'),
      def: v('defense'),
      spAtk: v('special-attack'),
      spDef: v('special-defense'),
      speed: v('speed'),
    );
  }

  Map<String, dynamic> toJson() => {
    'hp': hp, 'atk': atk, 'def': def, 'spAtk': spAtk, 'spDef': spDef, 'speed': speed,
  };

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
    hp: j['hp'], atk: j['atk'], def: j['def'], spAtk: j['spAtk'], spDef: j['spDef'], speed: j['speed'],
  );
}

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final Stats? stats;

  Pokemon({required this.id, required this.name, required this.imageUrl, this.stats});

  factory Pokemon.fromListItem(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final url  = json['url']  as String;
    final parts = url.split('/').where((e) => e.isNotEmpty).toList();
    final id = int.tryParse(parts.last) ?? 0;
    final sprite = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    return Pokemon(id: id, name: _title(name), imageUrl: sprite);
  }

  Pokemon copyWith({Stats? stats}) => Pokemon(
    id: id, name: name, imageUrl: imageUrl, stats: stats ?? this.stats,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'imageUrl': imageUrl, 'stats': stats?.toJson(),
  };

  factory Pokemon.fromJson(Map<String, dynamic> j) => Pokemon(
    id: j['id'], name: j['name'], imageUrl: j['imageUrl'],
    stats: j['stats'] == null ? null : Stats.fromJson(Map<String, dynamic>.from(j['stats'])),
  );

  static String _title(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

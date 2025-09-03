import 'package:get/get.dart';
import '../models/pokemon.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://pokeapi.co/api/v2';
    httpClient.timeout = const Duration(seconds: 10);
    super.onInit();
  }

  Future<List<Pokemon>> fetchPokemons({int limit = 20, int offset = 0}) async {
    final res = await get('/pokemon', query: {'limit': '$limit', 'offset': '$offset'});
    if (res.statusCode == 200 && res.body != null) {
      final results = (res.body['results'] as List).cast<Map<String, dynamic>>();
      return results.map((e) => Pokemon.fromListItem(e)).toList();
    }
    throw Exception('Failed to load Pokémon (${res.statusCode})');
  }

  Future<Stats> fetchPokemonStats(int id) async {
    final res = await get('/pokemon/$id');
    if (res.statusCode == 200 && res.body != null) {
      return Stats.fromApi(res.body['stats'] as List);
    }
    throw Exception('Failed to load stats for #$id');
  }
}

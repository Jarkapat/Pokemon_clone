import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/pokemon.dart';
import '../models/team.dart';
import '../services/api_service.dart';

class TeamController extends GetxController {
  final ApiService api = Get.find<ApiService>();
  final _box = GetStorage();

  // รายการทั้งหมด + ตัวกรอง
  final pokemons = <Pokemon>[].obs;
  final filtered = <Pokemon>[].obs;

  // ค้นหา
  final query = ''.obs;

  // สถานะโหลด/เออเรอร์
  final isLoading = false.obs;
  final error = RxnString();

  // selection หลักของหน้า Home (เลือก/ยกเลิก)
  final team = <Pokemon>[].obs;
  final teamName = 'My Team'.obs;

  // สเต็ตแคช
  final stats = <int, Stats>{}.obs;
  final Set<int> _loadingStats = {};

  // draft สำหรับสร้าง/แก้ทีม 3 ตัว
  final draftTeam = <Pokemon>[].obs;
  bool get draftReady => draftTeam.length == 3;
  void resetDraft() => draftTeam.clear();
  bool isInDraft(Pokemon p) => draftTeam.any((t) => t.id == p.id);
  void draftToggle(Pokemon p) {
    final exists = isInDraft(p);
    if (exists) {
      draftTeam.removeWhere((t) => t.id == p.id);
    } else {
      if (draftTeam.length >= 3) return;
      draftTeam.add(p.copyWith(stats: stats[p.id]));
    }
  }

  // รายชื่อทีมที่บันทึก
  final savedTeams = <TeamModel>[].obs;

  static const _kTeamKey = 'team';
  static const _kTeamNameKey = 'team_name';
  static const _kSavedTeamsKey = 'saved_teams';

  // ===== lifecycle =====
  @override
  void onInit() {
    super.onInit();
    _restoreTeam();
    _restoreSavedTeams();
    loadPokemons(initial: true);
    ever(query, (_) => _applyFilter());
    ever(pokemons, (_) => _applyFilter());
  }

  // ===== fetch =====
  var limit = 20;
  var offset = 0;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  Future<void> loadPokemons({bool initial = false}) async {
    if (initial) { isLoading.value = true; error.value = null; }
    try {
      final list = await api.fetchPokemons(limit: limit, offset: offset);
      if (initial) pokemons.assignAll(list); else pokemons.addAll(list);
      hasMore.value = list.length == limit;
    } catch (e) {
      error.value = e.toString();
    } finally {
      if (initial) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    offset += limit;
    try {
      final list = await api.fetchPokemons(limit: limit, offset: offset);
      pokemons.addAll(list);
      hasMore.value = list.length == limit;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ===== stats (on-demand) =====
  Future<void> ensureStats(int id) async {
    if (stats.containsKey(id) || _loadingStats.contains(id)) return;
    _loadingStats.add(id);
    try {
      final s = await api.fetchPokemonStats(id);
      stats[id] = s;
      // sync เข้าทีมถ้ามี id นี้
      final idx = team.indexWhere((t) => t.id == id);
      if (idx != -1 && team[idx].stats == null) {
        team[idx] = team[idx].copyWith(stats: s);
        _persistTeam();
      }
    } finally {
      _loadingStats.remove(id);
    }
  }

  // ===== filter/search =====
  void _applyFilter() {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) filtered.assignAll(pokemons);
    else filtered.assignAll(pokemons.where((p) => p.name.toLowerCase().contains(q)));
  }

  // ===== selection (หน้า Home) =====
  bool isSelected(Pokemon p) => team.any((t) => t.id == p.id);
  void toggle(Pokemon p) {
    final exists = isSelected(p);
    if (exists) team.removeWhere((t) => t.id == p.id);
    else {
      if (team.length >= 6) return; // cap 6 ถ้าไม่ต้องการลบออกได้
      team.add(p.copyWith(stats: stats[p.id]));
    }
    _persistTeam();
  }
  void resetTeam() { team.clear(); _persistTeam(); }
  void setTeamName(String name) {
    teamName.value = name.trim().isEmpty ? 'My Team' : name.trim();
    _box.write(_kTeamNameKey, teamName.value);
  }

  void _persistTeam() {
    _box.write(_kTeamKey, team.map((e) => e.toJson()).toList());
    _box.write(_kTeamNameKey, teamName.value);
  }

  void _restoreTeam() {
    final savedName = _box.read<String>(_kTeamNameKey);
    if (savedName != null && savedName.trim().isNotEmpty) teamName.value = savedName;
    final savedTeam = _box.read<List>(_kTeamKey);
    if (savedTeam != null) {
      final list = savedTeam.map((m) => Pokemon.fromJson(Map<String, dynamic>.from(m))).toList();
      team.assignAll(list);
      for (final p in list) { if (p.stats != null) stats[p.id] = p.stats!; }
    }
  }

  // ===== saved teams (3 ตัว) =====
  void _persistSavedTeams() => _box.write(_kSavedTeamsKey, savedTeams.map((e) => e.toJson()).toList());
  void _restoreSavedTeams() {
    final list = _box.read<List>(_kSavedTeamsKey);
    if (list != null) {
      savedTeams.assignAll(list.map((m) => TeamModel.fromJson(Map<String, dynamic>.from(m))));
    }
  }

  void confirmCreateTeam(String name) {
    if (!draftReady) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final t = TeamModel(id: id, name: name.trim().isEmpty ? 'Team $id' : name.trim(), members: draftTeam.toList());
    savedTeams.add(t);
    _persistSavedTeams();
    resetDraft();
  }

  void deleteTeam(String id) {
    savedTeams.removeWhere((t) => t.id == id);
    _persistSavedTeams();
  }

  void renameTeam(String id, String newName) {
    final idx = savedTeams.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final name = newName.trim().isEmpty ? savedTeams[idx].name : newName.trim();
    savedTeams[idx] = savedTeams[idx].copyWith(name: name);
    _persistSavedTeams();
  }

  void loadDraftFromTeam(String id) {
    final list = savedTeams.where((t) => t.id == id).toList();
    draftTeam
      ..clear()
      ..addAll(list.isEmpty ? <Pokemon>[] : list.first.members);
  }

  void updateTeamMembers(String id) {
    final idx = savedTeams.indexWhere((t) => t.id == id);
    if (idx == -1 || !draftReady) return;
    savedTeams[idx] = savedTeams[idx].copyWith(members: draftTeam.toList());
    _persistSavedTeams();
    resetDraft();
  }

  Future<void> refreshList() async {
    offset = 0;
    await loadPokemons(initial: true);
  }
}

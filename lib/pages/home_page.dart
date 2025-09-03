import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../widgets/pokemon_card.dart';
import 'create_team_page.dart';
import 'team_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(c.teamName.value)),
        actions: [
          IconButton(
            tooltip: 'รายชื่อทีม',
            icon: const Icon(Icons.groups_2),
            onPressed: () => Get.to(() => const TeamListPage()),
          ),
          IconButton(
            tooltip: 'Reset Team',
            onPressed: c.resetTeam,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ค้นหา
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search Pokémon',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => c.query.value = v,
              ),
            ),

            // ตัวนับจำนวนที่แสดง / ทั้งหมด
            Obx(() => Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('พบ ${c.filtered.length} ตัว (ทั้งหมด ${c.pokemons.length})'),
                  ),
                )),

            // กริดการ์ดโปเกมอน
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.error.value != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('เกิดข้อผิดพลาด:\n${c.error.value}', textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => c.refreshList(),
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  );
                }

                final list = c.filtered;
                if (list.isEmpty) {
                  return const Center(child: Text('ไม่พบข้อมูล'));
                }

                return LayoutBuilder(
                  builder: (ctx, cons) {
                    final w = cons.maxWidth;
                    final rawCols = (w ~/ 160);
                    final cols = rawCols.clamp(2, 4).toInt(); // ให้เป็น int ชัดเจน
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        mainAxisExtent: 220, // ปรับได้ตามดีไซน์
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final p = list[i];
                        c.ensureStats(p.id); // เพื่อคำนวณ BST บนการ์ด
                        return PokemonCard(pokemon: p);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          c.resetDraft();
          Get.to(() => const CreateTeamPage());
        },
        icon: const Icon(Icons.add),
        label: const Text('สร้างทีม (3 ตัว)'),
      ),
    );
  }
}

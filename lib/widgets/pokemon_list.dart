import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../widgets/stat_bars.dart';

class PokemonList extends StatelessWidget {
  const PokemonList({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search Pokémon',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => c.query.value = v,
          ),
        ),

        Expanded(
          child: Obx(() {
            if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
            if (c.error.value != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('เกิดข้อผิดพลาด:\n${c.error.value}', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () => c.refreshList(), child: const Text('ลองใหม่')),
                  ],
                ),
              );
            }

            final list = c.filtered;
            if (list.isEmpty) {
              return const Center(child: Text('ไม่พบข้อมูล'));
            }

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final p = list[i];
                // ดึงสเต็ตเฉพาะเมื่อยังไม่มี
                c.ensureStats(p.id);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Obx(() {
                      final stats = c.stats[p.id]; // รับจาก RxMap
                      final selected = c.isSelected(p);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.network(p.imageUrl, width: 56, height: 56),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(p.name,
                                    style: Theme.of(context).textTheme.titleMedium),
                              ),
                              IconButton(
                                tooltip: selected ? 'Remove from Team' : 'Add to Team',
                                onPressed: () => c.toggle(p),
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 150),
                                  child: selected
                                      ? const Icon(Icons.check_circle, key: ValueKey('on'))
                                      : const Icon(Icons.add_circle_outline, key: ValueKey('off')),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          StatBars(stats: stats), // แสดงค่าสถานะ
                        ],
                      );
                    }),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

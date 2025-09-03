// lib/widgets/pokemon_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/pokemon.dart';

class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;
  const PokemonCard({super.key, required this.pokemon});

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  void _tapAnim(VoidCallback onTap) async {
    setState(() => _scale = 0.96);
    await Future.delayed(const Duration(milliseconds: 70));
    if (!mounted) return;
    setState(() => _scale = 1);
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    final p = widget.pokemon;

    return Obx(() {
      final s = c.stats[p.id];
      final selected = c.isSelected(p);
      final bst = s == null ? null : (s.hp + s.atk + s.def + s.spAtk + s.spDef + s.speed);
      final borderColor = selected ? Colors.green : Theme.of(context).dividerColor;

      return AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _tapAnim(() => c.toggle(p)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: selected ? 3 : 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              children: [
                Row(children: [
                  Text(bst == null ? 'BST —' : 'BST $bst', style: Theme.of(context).textTheme.titleLarge),
                ]),
                const SizedBox(height: 6),
                SizedBox(height: 90, child: Image.network(p.imageUrl, fit: BoxFit.contain)),
                const SizedBox(height: 8),
                Text(p.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: selected ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

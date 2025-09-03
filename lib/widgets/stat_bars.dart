import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import 'stat_theme.dart';

class StatBars extends StatelessWidget {
  final Stats? stats;                 // อาจเป็น null ระหว่างโหลด
  final StatPalette palette;
  const StatBars({super.key, required this.stats, this.palette = StatPalette.harmonious});

  static const _maxBase = 255.0;

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return Column(children: List.generate(3, (i) => _placeholderLine()));
    }
    return Column(
      children: [
        _row(context, 'HP',  stats!.hp,    palette.hp),
        _row(context, 'ATK', stats!.atk,   palette.atk),
        _row(context, 'DEF', stats!.def,   palette.def),
        _row(context, 'SpA', stats!.spAtk, palette.spAtk),
        _row(context, 'SpD', stats!.spDef, palette.spDef),
        _row(context, 'SPD', stats!.speed, palette.speed),
      ],
    );
  }

  Widget _row(BuildContext ctx, String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(width: 34, child: Text(label, style: Theme.of(ctx).textTheme.labelSmall)),
          const SizedBox(width: 8),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (value / _maxBase).clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 300),
              builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: color.withOpacity(0.18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _placeholderLine() => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: const LinearProgressIndicator(minHeight: 8),
    ),
  );
}

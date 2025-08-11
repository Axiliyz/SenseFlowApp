import 'package:flutter/material.dart';
import '../../../models/session.dart';
import '../../../widgets/neon_card.dart';
import '../../../utils/ai_rules.dart';

class AiSummaryCard extends StatelessWidget {
  final Session? session;
  const AiSummaryCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    if (session == null) return const SizedBox.shrink();
    final a = analyzeSession(session!);
    final c = aiColor(context, a.level);

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(aiIcon(a.level), color: c, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800, color: c)),
                const SizedBox(height: 2),
                Text(a.subtitle, style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75))),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: a.reasons.map((r) => _pill(context, r)).toList(),
          ),
          const SizedBox(height: 12),
          Text('Рекомендации', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: a.suggestions.map((t)=> Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 4),
                Expanded(child: Text(t)),
              ]),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFEFF5FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(text, style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

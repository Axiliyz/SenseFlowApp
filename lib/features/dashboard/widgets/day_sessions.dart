import 'package:flutter/material.dart';
import '../../../../models/session.dart';
import '../../../../widgets/neon_card.dart';

class DaySessions extends StatelessWidget {
  final List<Session> sessionsForDay;
  final String? currentSessionName;
  final void Function(Session s) onTap;
  const DaySessions({super.key, required this.sessionsForDay, required this.currentSessionName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: NeonCard(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Выбранный день', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (sessionsForDay.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Нет измерений в этот день',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontStyle: FontStyle.italic),
                  ),
                )
              else
                for (var s in sessionsForDay)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      '${s.date.hour.toString().padLeft(2,'0')}:${s.date.minute.toString().padLeft(2,'0')}:${s.date.second.toString().padLeft(2,'0')}',
                      style: TextStyle(
                        color: currentSessionName == s.name
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    onTap: () => onTap(s),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

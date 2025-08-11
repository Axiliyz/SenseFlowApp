import 'package:flutter/material.dart';
import '../../../../models/session.dart';
import '../../../../widgets/neon_card.dart';

class RecentSessions extends StatelessWidget {
  final List<Session> sessions;
  final String? currentSessionName;
  final void Function(Session s) onTap;
  const RecentSessions({super.key, required this.sessions, required this.currentSessionName, required this.onTap});

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
              Text('Недавние сеансы', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (var session in sessions.take(5))
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(
                    '${session.date.day.toString().padLeft(2,'0')}.${session.date.month.toString().padLeft(2,'0')}.${session.date.year} '
                    '${session.date.hour.toString().padLeft(2,'0')}:${session.date.minute.toString().padLeft(2,'0')}:${session.date.second.toString().padLeft(2,'0')}',
                    style: TextStyle(
                      color: currentSessionName == session.name
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  onTap: () => onTap(session),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

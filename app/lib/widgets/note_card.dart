import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: note.isDone
          ? const Color(0xFF1A2E1A)
          : const Color(0xFF1E1E30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: note.isDone
              ? const Color(0xFF2A4A2A)
              : const Color(0xFF2A2A45),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: colorScheme.primary.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Иконка + заголовок
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: note.isDone
                          ? Colors.green.withOpacity(0.15)
                          : colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      note.isDone
                          ? Icons.check_circle
                          : Icons.sticky_note_2_outlined,
                      size: 14,
                      color: note.isDone ? Colors.green[400] : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: note.isDone
                            ? const Color(0xFF666680)
                            : const Color(0xFFE8E8FF),
                        decoration: note.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFF666680),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Текст заметки — Flexible чтобы не вылезал за границы
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    note.content,
                    style: TextStyle(
                      fontSize: 12,
                      color: note.isDone
                          ? const Color(0xFF444460)
                          : const Color(0xFF8888AA),
                      height: 1.5,
                      decoration: note.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF444460),
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Дата — всегда внизу
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 11,
                    color: Color(0xFF444460),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _formatDate(note.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF444460),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return 'Сегодня, ${_formatTime(date)}';
    }
    if (noteDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера, ${_formatTime(date)}';
    }
    return '${date.day}.${date.month}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';
import '../pages/detail/book_detail.dart';
import '../../data/datasources/memory.dart' show MemoryDataSource;
import '../../core/utils/money.dart';

class TodaySuggest extends StatelessWidget {
  const TodaySuggest({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.catalog.isEmpty) return const SizedBox();
    final book = app.catalog.first;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 84, height: 84,
                child: MemoryDataSource.safeImage(book.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gợi ý hôm nay', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(formatVnd(book.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetail(book: book)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

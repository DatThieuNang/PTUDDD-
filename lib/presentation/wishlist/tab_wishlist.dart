import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';
import '../../data/datasources/memory.dart' show MemoryDataSource;
import '../pages/detail/book_detail.dart';
import '../../core/utils/money.dart';

class TabWishlist extends StatelessWidget {
  const TabWishlist({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final books = app.catalog.where((b) => app.wishlistIds.contains(b.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Yêu thích')),
      body: books.isEmpty
          ? const Center(child: Text('Chưa có sách yêu thích'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: books.length,
              itemBuilder: (_, i) {
                final b = books[i];
                return InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetail(book: b))),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 72, height: 72,
                              child: MemoryDataSource.safeImage(b.image, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(b.author, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(formatVnd(b.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => app.toggleWishlist(b.id),
                            tooltip: 'Bỏ yêu thích',
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

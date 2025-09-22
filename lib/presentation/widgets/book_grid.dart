import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';
import '../../domain/entities/entities.dart';
import '../../data/datasources/memory.dart' show MemoryDataSource;
import '../../core/utils/money.dart';
import '../pages/detail/book_detail.dart';

class BookGrid extends StatelessWidget {
  final List<Book> books;
  final bool embed; // nếu true -> lưới không cuộn, dùng trong SingleChildScrollView

  const BookGrid({super.key, required this.books, this.embed = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final w = MediaQuery.of(context).size.width;
    final cross = w >= 1200 ? 6 : w >= 900 ? 4 : w >= 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68, // hơi cao để tránh overflow nút
      ),
      itemCount: books.length,
      shrinkWrap: embed,
      physics: embed ? const NeverScrollableScrollPhysics() : null,
      itemBuilder: (context, i) {
        final b = books[i];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetail(book: b))),
          child: Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                AspectRatio(aspectRatio: 3/2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MemoryDataSource.safeImage(b.image, fit: BoxFit.cover),
                      // Giá hiện tại (đã giảm nếu có)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            formatVnd(b.salePrice),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ),
                      // Badge giảm giá dạng pill gọn trong ảnh
                      if (b.salePercent > 0)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${b.salePercent}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[700]),
                            const SizedBox(width: 2),
                            Text(b.ratingAvg.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('Đã bán ${b.soldCount}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                        if (b.salePercent > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            formatVnd(b.price),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => app.addOne(b),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5), // giảm 2px để chắc chắn không overflow
                              shape: const StadiumBorder(),
                              elevation: 0.5,
                              backgroundColor: const Color(0xFFF2F2F7),
                              foregroundColor: Colors.black87,
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            child: const Text('Thêm vào giỏ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}




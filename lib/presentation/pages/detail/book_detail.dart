import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/state/app_state.dart';
import '../../../domain/entities/entities.dart';
import '../../../core/utils/money.dart';
import '../../../data/datasources/memory.dart' show MemoryDataSource;

class BookDetail extends StatefulWidget {
  final Book book;
  const BookDetail({super.key, required this.book});

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  final TextEditingController _cmtCtl = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _cmtCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final liked = app.wishlistIds.contains(widget.book.id);

    // Padding đáy động để tránh đè lên 2 nút bottom bar
    final bottomPad =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 24;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: liked ? 'Bỏ khỏi yêu thích' : 'Thêm vào yêu thích',
            icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
            onPressed: () => app.toggleWishlist(widget.book.id),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          app.getAverageRating(widget.book.id),
          app.getReviews(widget.book.id),
        ]),
        builder: (context, snap) {
          final has =
              snap.connectionState == ConnectionState.done && snap.hasData;
          final avg = has ? (snap.data![0] as double) : 0.0;
          final reviews =
              has ? (snap.data![1] as List<Review>) : const <Review>[];

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh + badge giá (hiển thị giá SALE)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: MemoryDataSource.safeImage(
                          widget.book.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            formatVnd(widget.book.salePrice),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      if (widget.book.salePercent > 0)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${widget.book.salePercent}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tên + tác giả
                Text(
                  widget.book.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.book.author,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // Giá chi tiết (sale + gạch giá gốc)
                Row(
                  children: [
                    Text(
                      formatVnd(widget.book.salePrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.book.salePercent > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        formatVnd(widget.book.price),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // === GIỚI THIỆU === (null-safe)
                if ((widget.book.description ?? '').isNotEmpty) ...[
                  const Text('Giới thiệu',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(widget.book.description!),
                  const SizedBox(height: 12),
                ],

                // Rating trung bình + số lượng
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < avg.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(avg.toStringAsFixed(1)),
                    const SizedBox(width: 6),
                    Text(
                      '(${reviews.length} đánh giá)',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Bình luận',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),

                if (snap.connectionState != ConnectionState.done)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (reviews.isEmpty)
                  const Text('Chưa có bình luận. Hãy là người đầu tiên!')
                else
                  ...reviews.reversed.map(
                    (r) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(r.rating.toString())),
                      title: Text(r.text),
                      subtitle: Text(
                        r.createdAt.toLocal().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Form đánh giá nhanh
                Row(
                  children: [
                    const Text('Đánh giá: '),
                    ...List.generate(5, (i) {
                      final idx = i + 1;
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() => _rating = idx),
                        icon: Icon(
                          idx <= _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ],
                ),
                TextField(
                  controller: _cmtCtl,
                  decoration: const InputDecoration(
                    hintText: 'Viết bình luận...',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final text = _cmtCtl.text.trim();
                      if (text.isEmpty) return;
                      await app.addReview(widget.book.id, _rating, text);
                      _cmtCtl.clear();
                      if (mounted) setState(() {});
                    },
                    child: const Text('Gửi'),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // Hai nút dưới
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => app.addOne(widget.book),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Thêm vào giỏ'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await app.buyNow(widget.book);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã mua ngay 1 cuốn')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

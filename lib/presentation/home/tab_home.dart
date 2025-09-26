import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';
import '../widgets/book_grid.dart';
import '../widgets/promo_banner.dart';
import '../widgets/flash_sale_strip.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});
  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  final TextEditingController _ctl = TextEditingController();
  final _pageCtl = PageController(viewportFraction: 0.88);
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();

    // Auto slide mini promos
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageCtl.hasClients) return;
      final next = ((_pageCtl.page ?? 0).round() + 1) % 3;
      _pageCtl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });

    // Để suffixIcon (nút clear) cập nhật khi người dùng gõ/xóa
    _ctl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtl.dispose();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          title: const Text('Sports Book Store'),
          actions: [
            // Nút chuông + badge số chưa đọc
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Thông báo',
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/notifications'),
                ),
                if (app.unreadNoti > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        app.unreadNoti > 9 ? '9+' : '${app.unreadNoti}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Ô tìm kiếm
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctl,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sách',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF3F6F9),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _ctl.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Xóa',
                              onPressed: () {
                                _ctl.clear();
                                app.doSearch('');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onSubmitted: (v) => app.doSearch(v),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.white,
                    elevation: 1,
                  ),
                  onPressed: () => app.doSearch(_ctl.text),
                  child: const Text('Tìm',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),

        // Banner lớn
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: PromoBanner(
              title: 'Giảm đến 30% sách bếp núc',
              subtitle: 'Ưu đãi trong tuần này',
              imageUrl:
                  'https://images.unsplash.com/photo-1512058564366-18510be2db19',
              onTap: () {},
            ),
          ),
        ),

        // Flash sale
        const SliverToBoxAdapter(child: FlashSaleStrip()),

        // Mini promos
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: PageView(
              controller: _pageCtl,
              children: const [
                _MiniPromoCard(
                  text: 'Combo học tập 2 cuốn',
                  imageUrl:
                      'https://images.unsplash.com/photo-1521587760476-6c12a4b040da',
                ),
                _MiniPromoCard(
                  text: 'Manga mới ra mắt',
                  imageUrl:
                      'https://images.unsplash.com/photo-1519681393784-d120267933ba',
                ),
                _MiniPromoCard(
                  text: 'Best-seller kinh doanh',
                  imageUrl:
                      'https://images.unsplash.com/photo-1454165205744-3b78555e5572',
                ),
              ],
            ),
          ),
        ),

        // Lưới sách nhúng
        SliverToBoxAdapter(
          child: BookGrid(books: app.catalogView, embed: true),
        ),
      ],
    );
  }
}

class _MiniPromoCard extends StatelessWidget {
  final String text;
  final String imageUrl;
  const _MiniPromoCard({required this.text, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFECEFF1)),
            ),
            Container(color: Colors.black.withOpacity(0.35)),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

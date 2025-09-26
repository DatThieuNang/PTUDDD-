import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';
import '../widgets/book_grid.dart';

class TabCatalog extends StatefulWidget {
  const TabCatalog({super.key});
  @override
  State<TabCatalog> createState() => _TabCatalogState();
}

class _TabCatalogState extends State<TabCatalog> {
  final _ctl = TextEditingController();
  Timer? _debounce;
  int _limit = 12;

  @override
  void dispose() {
    _ctl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<AppState>().doSearch(v);
      setState(() => _limit = 12); // reset phân trang khi tìm
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final booksAll = app.catalogView;
    final books = booksAll.take(_limit).toList();

    return CustomScrollView(
      slivers: [
        // Ô tìm kiếm
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _ctl,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: "Tìm kiếm danh mục",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF3F6F9),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: (_ctl.text.isEmpty)
                    ? null
                    : IconButton(
                        onPressed: () {
                          _ctl.clear();
                          context.read<AppState>().doSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
        ),

        // ===== KHỐI FILTER + CATEGORY + SORT (GHIM, NÂNG CHIỀU CAO) =====
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyFilters(
            // chiều cao rộng rãi để không tràn trên máy font lớn
            minExtent: 148,
            maxExtent: 148,
          ),
        ),

        // Lưới sách (nhúng, không cuộn độc lập)
        SliverToBoxAdapter(child: BookGrid(books: books, embed: true)),

        // Nút "Xem thêm"
        if (_limit < booksAll.length)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: OutlinedButton(
                  onPressed: () => setState(
                      () => _limit = (_limit + 12).clamp(0, booksAll.length)),
                  child: Text("Xem thêm (${booksAll.length - _limit})"),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StickyFilters extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  _StickyFilters({required this.minExtent, required this.maxExtent});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final app = context.watch<AppState>();
    final cats = <String>{"Tất cả", ...app.catalog.map((b) => b.category)}
        .toList(growable: false);

    Widget _fchip(String label, bool selected, IconData icon, VoidCallback on) {
      return FilterChip(
        label: Text(label),
        avatar: Icon(icon, size: 16),
        selected: selected,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onSelected: (_) => on(),
      );
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // hàng filter nhanh
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _fchip("Khuyến mãi", app.showPromo, Icons.local_offer,
                    () => context.read<AppState>().togglePromo()),
                const SizedBox(width: 8),
                _fchip("Bán chạy", app.showBestseller, Icons.whatshot,
                    () => context.read<AppState>().toggleBestseller()),
                const SizedBox(width: 8),
                _fchip("Mới ra mắt", app.showNew, Icons.fiber_new,
                    () => context.read<AppState>().toggleNew()),
              ],
            ),
          ),
          // hàng danh mục
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final c = cats[i];
                final selected =
                    (app.currentCategory ?? "") == (c == "Tất cả" ? "" : c);
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (_) => context
                      .read<AppState>()
                      .applyCategory(c == "Tất cả" ? "" : c),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: cats.length,
            ),
          ),
          // hàng sort
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: Row(
              children: const [
                _SortChip(
                    label: "Phổ biến",
                    type: SortType.popular,
                    icon: Icons.trending_up),
                SizedBox(width: 8),
                _SortChip(
                    label: "Mới nhất",
                    type: SortType.newest,
                    icon: Icons.new_releases_outlined),
                SizedBox(width: 8),
                _SortChip(
                    label: "Giá ↑",
                    type: SortType.priceAsc,
                    icon: Icons.keyboard_arrow_up),
                SizedBox(width: 8),
                _SortChip(
                    label: "Giá ↓",
                    type: SortType.priceDesc,
                    icon: Icons.keyboard_arrow_down),
                SizedBox(width: 8),
                _SortChip(
                    label: "Đánh giá",
                    type: SortType.rating,
                    icon: Icons.star_rate_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilters oldDelegate) =>
      minExtent != oldDelegate.minExtent || maxExtent != oldDelegate.maxExtent;
}

class _SortChip extends StatelessWidget {
  final String label;
  final SortType type;
  final IconData icon;
  const _SortChip(
      {required this.label, required this.type, required this.icon});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final selected = app.sortType == type;
    return ChoiceChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      selected: selected,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (_) => context.read<AppState>().setSort(type),
    );
  }
}

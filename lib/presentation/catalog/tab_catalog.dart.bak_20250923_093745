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
  final TextEditingController _ctl = TextEditingController();
  final categories = const ['Tất cả','Học tập','Nấu ăn','Truyện tranh','Kinh doanh','Tâm lý'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục sách')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctl,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên/tác giả/thể loại',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF3F6F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (v) => app.doSearch(v),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.white,
                    elevation: 1,
                  ),
                  onPressed: () => app.doSearch(_ctl.text),
                  child: const Text('Tìm', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Filter theo thể loại
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: categories.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(c),
                  selected: (app.currentCategory ?? '') == (c == 'Tất cả' ? '' : c),
                  onSelected: (_) => app.applyCategory(c == 'Tất cả' ? '' : c),
                ),
              )).toList(),
            ),
          ),
          // Sort bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Wrap(
              spacing: 8,
              children: [
                _SortChip(label: 'Phổ biến', type: SortType.popular),
                _SortChip(label: 'Mới nhất', type: SortType.newest),
                _SortChip(label: 'Giá ', type: SortType.priceAsc),
                _SortChip(label: 'Giá ', type: SortType.priceDesc),
                _SortChip(label: 'Đánh giá cao', type: SortType.rating),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(child: BookGrid(books: app.catalogView)),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final SortType type;
  const _SortChip({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final selected = app.sortType == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => context.read<AppState>().setSort(type),
    );
  }
}

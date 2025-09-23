import "dart:async";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../application/state/app_state.dart";
import "../widgets/book_grid.dart";

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
  void dispose() { _ctl.dispose(); _debounce?.cancel(); super.dispose(); }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<AppState>().doSearch(v);
      setState(()=> _limit = 12); // reset phân trang khi tìm kiếm
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final booksAll = app.catalogView;
    final books = booksAll.take(_limit).toList();

    final cats = <String>{"Tất cả", ...app.catalog.map((b)=>b.category)}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _ctl,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: "Tìm kiếm danh mục",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF3F6F9),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Wrap(
            spacing: 8, runSpacing: -6,
            children: [
              FilterChip(selected: app.showPromo, label: const Text("Khuyến mãi"), onSelected: (_)=>context.read<AppState>().togglePromo(), avatar: const Icon(Icons.local_offer, size: 16)),
              FilterChip(selected: app.showBestseller, label: const Text("Bán chạy"), onSelected: (_)=>context.read<AppState>().toggleBestseller(), avatar: const Icon(Icons.whatshot, size: 16)),
              FilterChip(selected: app.showNew, label: const Text("Mới ra mắt"), onSelected: (_)=>context.read<AppState>().toggleNew(), avatar: const Icon(Icons.fiber_new, size: 16)),
            ],
          ),
        ),

        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final c=cats[i];
              final selected=(app.currentCategory??"")== (c=="Tất cả"?"":c);
              return ChoiceChip(label: Text(c), selected: selected, onSelected: (_)=>context.read<AppState>().applyCategory(c=="Tất cả"?"":c));
            },
            separatorBuilder: (_, __)=> const SizedBox(width: 8),
            itemCount: cats.length,
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Wrap(
            spacing: 8, runSpacing: -6,
            children: const [
              _SortChip(label: "Phổ biến", type: SortType.popular, icon: Icons.trending_up),
              _SortChip(label: "Mới nhất", type: SortType.newest, icon: Icons.new_releases_outlined),
              _SortChip(label: "Giá ", type: SortType.priceAsc, icon: Icons.keyboard_arrow_up),
              _SortChip(label: "Giá ", type: SortType.priceDesc, icon: Icons.keyboard_arrow_down),
              _SortChip(label: "Đánh giá", type: SortType.rating, icon: Icons.star_rate_rounded),
            ],
          ),
        ),

        const SizedBox(height: 4),
        Expanded(
          child: Column(
            children: [
              Expanded(child: BookGrid(books: books)),
              if (_limit < booksAll.length)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    onPressed: ()=> setState(()=> _limit = (_limit + 12).clamp(0, booksAll.length)),
                    child: Text("Xem thêm (${booksAll.length - _limit})"),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label; final SortType type; final IconData icon;
  const _SortChip({required this.label, required this.type, required this.icon});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final selected = app.sortType == type;
    return ChoiceChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      selected: selected,
      onSelected: (_)=> context.read<AppState>().setSort(type),
    );
  }
}

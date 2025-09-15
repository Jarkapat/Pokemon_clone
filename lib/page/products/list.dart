import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'edit.dart';
import 'dart:async';
typedef UnsubscribeFunc = Future<void> Function();

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final PocketBase pb = PocketBase('http://127.0.0.1:8090'); // Change to your PocketBase URL
  final ScrollController _scrollController = ScrollController();
  final List<RecordModel> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _perPage = 20;

  UnsubscribeFunc? _unsubscribeRealtime;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  pb.collection('product').subscribe('*', (e) {
      // On any create/update/delete, refresh the list from scratch
      setState(() {
        _products.clear();
        _page = 1;
        _hasMore = true;
      });
      _fetchProducts();
    }).then((unsubscribe) {
      _unsubscribeRealtime = unsubscribe;
    });
  }

  @override
  void dispose() {
    if (_unsubscribeRealtime != null) {
      _unsubscribeRealtime!();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
  final result = await pb.collection('product').getList(page: _page, perPage: _perPage);
      setState(() {
        _products.addAll(result.items);
        _hasMore = result.items.length == _perPage;
        if (_hasMore) _page++;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: _products.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _products.clear();
                  _page = 1;
                  _hasMore = true;
                });
                await _fetchProducts();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _products.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _products.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final product = _products[index];
                  final imageUrl = product.data['imageUrl'] as String?;
                  return ListTile(
                    leading: imageUrl != null && imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                            ),
                          )
                        : const Icon(Icons.shopping_bag),
                    title: Text(product.data['name'] ?? 'No Name'),
                    subtitle: Text(product.data['price']?.toString() ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepPurple),
                      tooltip: 'Edit',
                      onPressed: () async {
                        final updated = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProductEditPage(
                              product: product,
                              pb: pb,
                            ),
                          ),
                        );
                        if (updated == true) {
                          setState(() {
                            _products.clear();
                            _page = 1;
                            _hasMore = true;
                          });
                          await _fetchProducts();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

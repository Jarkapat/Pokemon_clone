import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shopapp/page/products/list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PocketBase pb = PocketBase('http://127.0.0.1:8090');
  late final PageController _pageController;
  int _currentPage = 0;
  List<RecordModel> _products = [];
  bool _loadingProducts = true;
  String? _productError;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.6);
    _fetchProducts();

  }

  Future<void> _fetchProducts() async {
    setState(() {
      _loadingProducts = true;
      _productError = null;
    });
    try {
      final result = await pb.collection('product').getList(page: 1, perPage: 10, sort: '-created');
      setState(() {
        _products = result.items;
      });
    } catch (e) {
      setState(() {
        _productError = e.toString();
      });
    } finally {
      setState(() {
        _loadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<RecordModel>> fetchTopProducts() async {
    final result = await pb.collection('product').getList(page: 1, perPage: 10, sort: '-created');
    return result.items;
  }

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {"user": "Alice", "comment": "Great shopping experience!", "rating": 5},
      {"user": "John", "comment": "Fast delivery and nice products.", "rating": 4},
      {"user": "Sophia", "comment": "Good quality for the price.", "rating": 5},
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Text(
              "Ecommerch",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProductListPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.deepPurple),
            tooltip: 'View Products',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Top Products (from PocketBase)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top Products",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.deepPurple),
                      onPressed: () {
                        if (_currentPage > 0) {
                          setState(() {
                            _currentPage--;
                          });
                          _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                      onPressed: () {
                        if (_currentPage < _products.length - 1) {
                          setState(() {
                            _currentPage++;
                          });
                          _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 270,
              child: _loadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : _productError != null
                      ? Center(child: Text('Error: \\${_productError}'))
                      : _products.isEmpty
                          ? const Center(child: Text('No products found.'))
                          : PageView.builder(
                              controller: _pageController,
                              itemCount: _products.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                final isActive = index == _currentPage;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                  margin: EdgeInsets.symmetric(horizontal: isActive ? 12 : 20, vertical: isActive ? 0 : 20),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.deepPurple.shade50 : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isActive ? Colors.deepPurple.withOpacity(0.2) : Colors.grey.shade200,
                                        blurRadius: isActive ? 16 : 8,
                                        offset: const Offset(0, 8),
                                      )
                                    ],
                                    border: isActive ? Border.all(color: Colors.deepPurple, width: 2) : null,
                                  ),
                                  width: isActive ? 200 : 160,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                        child: product.data['imageUrl'] != null
                                            ? Image.network(
                                                product.data['imageUrl'],
                                                height: isActive ? 140 : 110,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                height: isActive ? 140 : 110,
                                                color: Colors.grey[200],
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(product.data['name'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isActive ? 18 : 15, color: Colors.deepPurple)),
                                            const SizedBox(height: 4),
                                            Text('฿' + (product.data['price']?.toString() ?? ''), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.deepPurple,
                                                  minimumSize: const Size.fromHeight(36),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),

            const SizedBox(height: 24),

            /// Popular Reviews
            const Text(
              "Popular Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: reviews.map((review) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 5,
                        offset: const Offset(2, 4),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review["user"] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(review["comment"] as String),
                            const SizedBox(height: 6),
                            Row(
                              children: List.generate(
                                5,
                                (star) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: star < ((review["rating"] ?? 0) as int) ? Colors.amber : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
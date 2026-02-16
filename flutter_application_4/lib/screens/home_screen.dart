import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'cart_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<CartItem> cart = [];
  String searchQuery = "";
  String selectedCategory = "Hepsi";
  List<String> categories = ["Hepsi", "Lamba", "Koltuk", "Sandalye", "Masa"];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    final String response = await rootBundle.loadString('assets/data/products.json');
    final data = await json.decode(response);
    setState(() {
      products = (data as List).map((i) => Product.fromJson(i)).toList();
    });
  }

  // Bu fonksiyon hem HomeScreen'den hem DetailScreen'den çağrılabilecek
  void addToCart(Product product) {
    setState(() {
      int index = cart.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        cart[index].quantity++;
      } else {
        cart.add(CartItem(product: product, quantity: 1));
      }
    });
    
    // Küçük bir görsel bildirim
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Varsa eskisini kapat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} sepete eklendi"),
        backgroundColor: const Color(0xFF333333),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((p) {
      final matchesCategory = selectedCategory == "Hepsi" || p.category == selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0058AB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "HOME DECO",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white, fontSize: 18),
        ),
        actions: [
          _buildCartBadge(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryList(),
          _buildProductGrid(filteredProducts),
        ],
      ),
    );
  }

  Widget _buildCartBadge() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: IconButton(
        icon: Badge(
          label: Text(cart.fold(0, (sum, item) => sum + item.quantity).toString()),
          isLabelVisible: cart.isNotEmpty,
          backgroundColor: const Color(0xFFFFDA1A),
          textColor: Colors.black,
          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen(cartItems: cart)),
        ).then((_) => setState(() {})), // Sepetten dönünce sayıyı güncelle
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF0058AB),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: const InputDecoration(
            hintText: "Ürün ara...",
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Color(0xFF0058AB)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0058AB) : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> filteredProducts) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            product: product,
            onAddToCart: addToCart, // KRİTİK DÜZELTME: Fonksiyonu detay sayfasına gönderiyoruz
          ),
        ),
      ).then((_) => setState(() {})), // Detaydan dönünce badge güncellensin
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: product.id,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Image.network(product.image, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Icon(
                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: product.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${product.price.toStringAsFixed(0)} TL",
                        style: const TextStyle(color: Color(0xFF0058AB), fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFFFFDA1A), shape: BoxShape.circle),
                          child: const Icon(Icons.add, size: 20, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
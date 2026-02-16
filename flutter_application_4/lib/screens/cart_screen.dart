import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Toplam tutarı hesaplayan fonksiyon
  double get totalProductPrice => widget.cartItems.fold(
      0, (sum, item) => sum + (item.product.price * item.quantity));

  // Kargo ücreti (Örnek: 500 TL üzeri ücretsiz)
  double get shippingFee => totalProductPrice > 500 ? 0 : 49.90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Sayfa arka planı hafif gri
      appBar: AppBar(
        backgroundColor: const Color(0xFF0058AB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "SEPETİM",
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5, 
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.cartItems.isEmpty ? _buildEmptyCart() : _buildCartList(),
      bottomNavigationBar: widget.cartItems.isEmpty ? null : _buildCheckoutSection(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFF0058AB)),
          ),
          const SizedBox(height: 24),
          const Text(
            "Sepetinizde ürün bulunmuyor.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Alışverişe Başla", 
              style: TextStyle(color: Color(0xFF0058AB), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: widget.cartItems.length,
      itemBuilder: (context, index) {
        final item = widget.cartItems[index];
        return Dismissible(
          key: Key(item.product.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
          ),
          onDismissed: (direction) {
            setState(() {
              widget.cartItems.removeAt(index);
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Row(
              children: [
                // Görsel Alanı
                Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.network(item.product.image, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${item.product.price.toStringAsFixed(0)} TL",
                        style: const TextStyle(
                          color: Color(0xFF0058AB), 
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // Adet Kontrolü (Dikey Tasarım)
                Column(
                  children: [
                    _quantityCircle(Icons.add, () => setState(() => item.quantity++)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    _quantityCircle(Icons.remove, () {
                      if (item.quantity > 1) setState(() => item.quantity--);
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quantityCircle(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow("Ara Toplam", "${totalProductPrice.toStringAsFixed(2)} TL"),
          const SizedBox(height: 8),
          _summaryRow("Kargo", shippingFee == 0 ? "Ücretsiz" : "${shippingFee.toStringAsFixed(2)} TL", isGreen: shippingFee == 0),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TOPLAM", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "${(totalProductPrice + shippingFee).toStringAsFixed(0)} TL",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0058AB)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFDA1A),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {},
              child: const Text(
                "ÖDEMEYE GEÇ", 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 15,
            color: isGreen ? Colors.green : Colors.black,
          )
        ),
      ],
    );
  }
}
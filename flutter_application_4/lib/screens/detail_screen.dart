import 'package:flutter/material.dart';
import '../models/product.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  // Yeni eklenen satır: Sepete ekleme fonksiyonunu dışarıdan alıyoruz
  final Function(Product) onAddToCart; 

  const DetailScreen({super.key, required this.product, required this.onAddToCart});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1, height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  _buildPriceSection(),
                  const SizedBox(height: 32),
                  _buildInfoGrid(),
                  const SizedBox(height: 32),
                  _buildColorPicker(),
                  const SizedBox(height: 32),
                  const Text("Ürün Bilgileri", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  // --- Widget Parçaları (AppBar, ImageSection vb. aynı kalıyor) ---
  
  // Sadece buildBottomAction kısmındaki onPressed'i güncelledik:
  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        children: [
          _actionIconButton(Icons.shopping_bag_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDA1A),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () {
                  // GERÇEK EKLEME İŞLEMİ BURADA YAPILIYOR:
                  widget.onAddToCart(widget.product); 
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${widget.product.name} sepete eklendi!"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
                child: const Text("SEPETE EKLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Diğer yardımcı widgetları (appBar, imageSection, infoGrid, colorPicker, actionIconButton) 
  // eski kodundan olduğu gibi buraya kopyalayabilirsin.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0058AB),
      elevation: 0,
      centerTitle: true,
      title: const Text("HOME DECO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.5, fontSize: 18)),
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: const BoxDecoration(color: Color(0xFFF9F9F9), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40))),
      child: Hero(tag: widget.product.id, child: Padding(padding: const EdgeInsets.all(40.0), child: Image.network(widget.product.image, fit: BoxFit.contain))),
    );
  }

  Widget _buildStatusRow() {
    return Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF0058AB).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(widget.product.category.toUpperCase(), style: const TextStyle(color: Color(0xFF0058AB), fontSize: 11, fontWeight: FontWeight.bold))),
      const Spacer(),
      const Icon(Icons.flash_on, color: Colors.orange, size: 18),
      const Text("Hızlı Teslimat", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
    ]);
  }

  Widget _buildPriceSection() {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text("${widget.product.price.toStringAsFixed(0)} TL", style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF0058AB), letterSpacing: -1)),
      const Padding(padding: EdgeInsets.only(left: 8, bottom: 8), child: Text("KDV Dahil", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500))),
    ]);
  }

  Widget _buildInfoGrid() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _infoCard(Icons.straighten, "Boyut", "80x120"),
      _infoCard(Icons.eco_outlined, "Malzeme", "Masif"),
      _infoCard(Icons.star_outline, "Puan", "4.8"),
    ]);
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(width: (MediaQuery.of(context).size.width - 70) / 3, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(20)), child: Column(children: [Icon(icon, color: Colors.black87, size: 24), const SizedBox(height: 8), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]));
  }

  Widget _buildColorPicker() {
    final colors = [const Color(0xFF4A3728), const Color(0xFFE5E5E5), const Color(0xFF1A1A1A)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Renk Seçeneği", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: List.generate(colors.length, (index) => GestureDetector(onTap: () => setState(() => selectedColorIndex = index), child: Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selectedColorIndex == index ? const Color(0xFF0058AB) : Colors.transparent, width: 2)), child: CircleAvatar(backgroundColor: colors[index], radius: 15))))),
    ]);
  }

  Widget _actionIconButton(IconData icon) {
    return Container(height: 60, width: 60, decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: Colors.black));
  }
}
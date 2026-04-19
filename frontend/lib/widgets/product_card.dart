import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final str = intPrice.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
      result.write(str[i]);
    }
    return '\$ ${result.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: const Color(0xFFF5F5F5),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: Image.asset(
                                  'assets/Geometric_shape_loader.gif',
                                  width: 64,
                                  height: 64,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _ProductPlaceholder(
                              category: product.category,
                            ),
                          )
                        : _ProductPlaceholder(category: product.category),
                  ),
                ),
                if (product.discountPercent != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${product.discountPercent!.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(product.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
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

class _ProductPlaceholder extends StatelessWidget {
  final String category;

  const _ProductPlaceholder({required this.category});

  IconData _iconForCategory(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('zapato') || lower.contains('tenis') || lower.contains('calzado')) {
      return Icons.sports_handball;
    }
    if (lower.contains('ropa') || lower.contains('camisa') || lower.contains('camiseta')) {
      return Icons.checkroom;
    }
    if (lower.contains('deporte')) return Icons.fitness_center;
    return Icons.inventory_2_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        _iconForCategory(category),
        size: 56,
        color: const Color(0xFFBDBDBD),
      ),
    );
  }
}

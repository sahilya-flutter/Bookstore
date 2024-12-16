import 'package:book_store/account/addres_screen.dart';
// import 'package:book_store/account/order.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final List<CartItemData> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get totalPrice {
    return widget.cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _increaseQuantity(int index) {
    setState(() {
      widget.cartItems[index].quantity++;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (widget.cartItems[index].quantity > 1) {
        widget.cartItems[index].quantity--;
      } else {
        widget.cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return CartItem(
                    title: item.title,
                    price: item.price,
                    quantity: item.quantity,
                    imageUrl: item.imageUrl,
                    onIncrease: () => _increaseQuantity(index),
                    onDecrease: () => _decreaseQuantity(index),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL:',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(252, 2, 22, 1),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddressFormScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'PLACE ORDER',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

class CartItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[500],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove, color: Colors.white),
              ),
              Text(
                '$quantity',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartItemData {
  final String imageUrl;
  final String title;
  final double price;
  int quantity;

  CartItemData({
    required this.imageUrl,
    required this.title,
    required this.price,
    this.quantity = 1,
  });
}


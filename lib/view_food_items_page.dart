import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'edit_food_item_page.dart'; // Import EditFoodItemPage

class ViewFoodItemsPage extends StatefulWidget {
  final User user; // Add user parameter

  const ViewFoodItemsPage({super.key, required this.user});

  @override
  _ViewFoodItemsPageState createState() => _ViewFoodItemsPageState();
}

class _ViewFoodItemsPageState extends State<ViewFoodItemsPage> {
  String _selectedCategoryFilter = 'All';
  final List<String> _categories = ['All', 'Fruit', 'Vegetable', 'Dairy', 'Meat', 'Grain'];

  String _getExpiryText(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    if (difference > 0) {
      return '$difference days left';
    } else if (difference == 0) {
      return 'Expires today';
    } else {
      return 'Expired ${-difference} days ago';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Fruit':
        return Icons.apple;
      case 'Vegetable':
        return Icons.eco;
      case 'Dairy':
        return Icons.local_drink;
      case 'Meat':
        return Icons.restaurant;
      case 'Grain':
        return Icons.rice_bowl;
      default:
        return Icons.fastfood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryFilter,
                          decoration: const InputDecoration(labelText: 'Filter by Category'),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategoryFilter = newValue!;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .collection('fridge')
            .orderBy('expiryDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final foodItems = snapshot.data!.docs.where((doc) {
            if (_selectedCategoryFilter == 'All') {
              return true;
            }
            return doc['category'] == _selectedCategoryFilter;
          }).toList();
          if (foodItems.isEmpty) {
            return const Center(child: Text('No food items available.'));
          }
          return ListView.builder(
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              final foodItem = foodItems[index];
              final expiryDate = foodItem['expiryDate'].toDate();
              final expiryText = _getExpiryText(expiryDate);
              final categoryIcon = _getCategoryIcon(foodItem['category']);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: foodItem['image'] != null && foodItem['image'].isNotEmpty
                      ? Image.network(foodItem['image'], width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(categoryIcon, size: 50), // Use category-specific icon
                  title: Text(foodItem['name']),
                  subtitle: Text('Category: ${foodItem['category']}\nExpiry Date: $expiryText'),
                  trailing: Text('Quantity: ${foodItem['quantity']} ${foodItem['unit']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditFoodItemPage(foodItem: foodItem, user: widget.user)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

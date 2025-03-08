import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class EditFoodItemPage extends StatefulWidget {
  final DocumentSnapshot foodItem;
  final User user; // Add user parameter

  const EditFoodItemPage({super.key, required this.foodItem, required this.user});

  @override
  _EditFoodItemPageState createState() => _EditFoodItemPageState();
}

class _EditFoodItemPageState extends State<EditFoodItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController; // Add a controller for expiry date
  String? _selectedCategory;
  String? _selectedUnit;

  final List<String> _categories = ['Fruit', 'Vegetable', 'Dairy', 'Meat', 'Grain'];
  final Map<String, List<String>> _units = {
    'Fruit': ['buah'],
    'Vegetable': ['buah'],
    'Dairy': ['liter', 'botol'],
    'Meat': ['gram', 'kg'],
    'Grain': ['gram', 'kg'],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem['name']);
    _quantityController = TextEditingController(text: widget.foodItem['quantity'].toString().split(' ')[0]);
    _expiryDateController = TextEditingController(text: widget.foodItem['expiryDate'].toDate().toString().split(' ')[0]); // Initialize the controller
    _selectedCategory = widget.foodItem['category'];
    _selectedUnit = widget.foodItem['quantity'].toString().split(' ')[1];
  }

  Future<void> _updateFoodItem() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('food_items')
          .doc(widget.foodItem.id)
          .update({
        'name': _nameController.text,
        'category': _selectedCategory,
        'expiryDate': DateTime.parse(_expiryDateController.text),
        'quantity': '${_quantityController.text} $_selectedUnit',
      });
      Navigator.pop(context);
    }
  }

  Future<void> _deleteFoodItem() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('food_items')
        .doc(widget.foodItem.id)
        .delete();
    Navigator.pop(context);
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDateController.text.isNotEmpty ? DateTime.parse(_expiryDateController.text) : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = picked.toLocal().toString().split(' ')[0]; // Update the controller
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Food Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    _selectedUnit = _units[newValue]!.first; // Set default unit
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expiryDateController, // Use the controller
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'Select Date',
                ),
                onTap: () => _selectExpiryDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an expiry date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: _selectedCategory != null
                    ? _units[_selectedCategory]!.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList()
                    : [],
                onChanged: (newValue) {
                  setState(() {
                    _selectedUnit = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateFoodItem,
                child: const Text('Update Food Item'),
              ),
              ElevatedButton(
                onPressed: _deleteFoodItem,
                child: const Text('Delete Food Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

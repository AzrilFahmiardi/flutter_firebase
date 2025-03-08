import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:http/http.dart' as http; // Import http
import 'dart:convert'; // Import dart:convert for jsonDecode
import 'dart:io'; // Import dart:io for File
import 'utils.dart'; // Import showErrorDialog
import 'package:http_parser/http_parser.dart';

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
  File? _imageFile; // Add a File variable for the image
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
    _selectedUnit = widget.foodItem['quantity'].toString().split(' ').length > 1 ? widget.foodItem['quantity'].toString().split(' ')[1] : null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToCloudinary(File imageFile) async {
    try {
      final cloudName = 'dboezhsai'; // Cloud name Anda
      final uploadPreset = 'ml_default'; // Nama upload preset yang telah dikonfigurasi

      // URL untuk upload ke Cloudinary
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      // Buat nama file unik dengan timestamp
      final fileName = 'food_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Siapkan ByteStream dari file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      
      // Buat MultipartFile
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'), // Sesuaikan dengan jenis file yang diupload
      );
      
      // Siapkan MultipartRequest
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString()
        ..files.add(multipartFile);
      
      // Tampilkan log untuk debugging
      print('Mengirim upload request ke Cloudinary...');
      
      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Log status dan respons
      print('Cloudinary response status: ${response.statusCode}');
      print('Cloudinary response body: ${response.body}');
      
      // Parse respons
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Upload berhasil. URL gambar: ${jsonResponse['secure_url']}');
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Upload gagal: Status ${response.statusCode}, Respons: ${response.body}');
      }
    } catch (e) {
      print('Error saat upload gambar: $e');
      throw Exception('Gagal upload gambar: $e');
    }
  }

  Future<void> _updateFoodItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Upload the image to Cloudinary and get the download URL
        String imageUrl = widget.foodItem['image'];
        if (_imageFile != null) {
          imageUrl = await _uploadImageToCloudinary(_imageFile!);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .collection('fridge')
            .doc(widget.foodItem.id)
            .update({
          'name': _nameController.text,
          'category': _selectedCategory,
          'expiryDate': DateTime.parse(_expiryDateController.text),
          'quantity': int.parse(_quantityController.text),
          'unit': _selectedUnit,
          'image': imageUrl,
        });
        Navigator.pop(context);
      } catch (e) {
        showErrorDialog(context, 'Failed to update food item', e.toString());
      }
    }
  }

  Future<void> _deleteFoodItem() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('fridge')
          .doc(widget.foodItem.id)
          .delete();
      Navigator.pop(context);
    } catch (e) {
      showErrorDialog(context, 'Failed to delete food item', e.toString());
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _imageFile == null
                      ? widget.foodItem['image'] != null && widget.foodItem['image'].isNotEmpty
                          ? Image.network(widget.foodItem['image'], width: 100, height: 100)
                          : const Text('No image selected.')
                      : Image.file(_imageFile!, width: 100, height: 100),
                  const SizedBox(width: 10),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text('Capture Image'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text('Select from Gallery'),
                    ),
                  ),
                ],
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

import 'package:flutter/material.dart';
import 'package:mobile_lab_3/controllers/gift_controller.dart';
import 'package:mobile_lab_3/models/gift.dart';
import '../layouts/custom_title.dart';
import '../layouts/navbar.dart';

class GiftDetailsScreen extends StatefulWidget {
  GiftDetailsScreen({super.key});

  @override
  _GiftDetailsScreenState createState() => _GiftDetailsScreenState();
}

class _GiftDetailsScreenState extends State<GiftDetailsScreen> {
  late Gift gift;
  final GiftController _giftController = GiftController();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  bool _isEditingTitle = false;
  bool _isEditingCategory = false;
  bool _isEditingPrice = false;
  bool _isEditingDescription = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Gift?;
    if (args != null) {
      gift = args;
      _titleController = TextEditingController(text: gift.title);
      _categoryController = TextEditingController(text: gift.category);
      _priceController = TextEditingController(text: gift.price);
      _descriptionController = TextEditingController(text: gift.description ?? '');
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _categoryController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEditTitle() {
    setState(() {
      _isEditingTitle = !_isEditingTitle;
    });
  }

  void _toggleEditCategory() {
    setState(() {
      _isEditingCategory = !_isEditingCategory;
    });
  }

  void _toggleEditPrice() {
    setState(() {
      _isEditingPrice = !_isEditingPrice;
    });
  }

  void _toggleEditDescription() {
    setState(() {
      _isEditingDescription = !_isEditingDescription;
    });
  }

  void _saveChanges() async {
    Gift updatedGift = Gift(
      id: gift.id,
      title: _titleController.text,
      category: _categoryController.text,
      price: _priceController.text,
      description: _descriptionController.text,
      isPledged: gift.isPledged,
      eventId: gift.eventId
    );
    await _giftController.updateGift(updatedGift);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gift details updated successfully!')),
    );
    setState(() {
      gift = updatedGift;
    });
    Navigator.pushNamed(context, '/gifts');
  }

  void _deleteGift() async {
    if(gift.isPledged){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pledged Gifts can\'t be deleted')),
      );
      return;
    }
    await _giftController.deleteGift(gift.id!);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gift deleted successfully!')),
    );
    Navigator.pushNamed(context, '/gifts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitle(),
      bottomNavigationBar: CustomNavBar(selectedIndex: 4, highlightSelected: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gift Details',
              style: TextStyle(
                fontFamily: 'Aclonica',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDB2367),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center, // Center the icon in the container
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD700).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Icon(
                    Icons.card_giftcard, // Replace with the desired gift icon
                    color: Color(0xFFDB2367),
                    size: 140, // Adjust size to fit most of the container
                  ),
                ],
              ),
            ),


            SizedBox(height: 16),
            DetailRow(
              title: 'Name',
              value: gift.title,
              onEdit: _toggleEditTitle,
              controller: _titleController,
              isEditing: _isEditingTitle,
              isPledged: gift.isPledged,
            ),
            SizedBox(height: 8),
            DetailRow(
              title: 'Description',
              value: gift.description ?? '',
              onEdit: _toggleEditDescription,
              controller: _descriptionController,
              isEditing: _isEditingDescription,
              isPledged: gift.isPledged,
            ),
            SizedBox(height: 8),
            DetailRow(
              title: 'Price',
              value: gift.price,
              onEdit: _toggleEditPrice,
              controller: _priceController,
              isEditing: _isEditingPrice,
              isPledged: gift.isPledged
            ),
            SizedBox(height: 8),
            DetailRow(
              title: 'Category',
              value: gift.category,
              onEdit: _toggleEditCategory,
              controller: _categoryController,
              isEditing: _isEditingCategory,
              isPledged: gift.isPledged,
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  flex: 2, // Give more space to the Save button
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD700),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1, // Give less space to the Delete button
                  child: ElevatedButton(
                    onPressed: _deleteGift,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}


class DetailRow extends StatefulWidget {
  final String title;
  final String value;
  final TextEditingController controller;
  final VoidCallback onEdit;
  final bool isEditing;
  final bool isPledged;

  const DetailRow({
    required this.title,
    required this.value,
    required this.onEdit,
    required this.controller,
    required this.isEditing,
    required this.isPledged,
    Key? key,
  }) : super(key: key);

  @override
  _DetailRowState createState() => _DetailRowState();
}

class _DetailRowState extends State<DetailRow> {
  late bool isEditing;
  late String oldValue;

  @override
  void initState() {
    super.initState();
    isEditing = false;
    oldValue = widget.value;
    widget.controller.text = widget.value;
  }

  void _toggleEditing() {
    if(widget.isPledged){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pledged Gifts can\'t be edited')),
      );
      return;
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveChanges() {
    setState(() {
      oldValue = widget.controller.text; // Save the new value
      isEditing = false;
      widget.onEdit();
    });
  }

  void _cancelEditing() {
    setState(() {
      widget.controller.text = oldValue; // Revert to the old value
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Aclonica',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0), // Space between title and value
                isEditing
                    ? TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                  ),
                )
                    : Text(
                  oldValue,
                  style: const TextStyle(
                    fontFamily: 'Aclonica',
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _saveChanges, // Save changes and close editing
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _cancelEditing, // Cancel changes and revert to old value
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFDB2367)),
              onPressed: _toggleEditing, // Enter editing mode
            ),
        ],
      ),
    );
  }
}


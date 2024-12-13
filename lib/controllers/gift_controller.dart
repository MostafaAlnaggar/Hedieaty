import 'package:mobile_lab_3/database/gift_dao.dart';
import 'package:mobile_lab_3/models/gift.dart';

class GiftController {
  final GiftDAO _dao = GiftDAO();

  // Get all gifts
  Future<List<Gift>> getAllGifts() async {
    return await _dao.readAll();
  }

  // Add a new gift
  Future<void> addGift(Gift gift) async {
    await _dao.create(gift);
  }

  // Update an existing gift
  Future<void> updateGift(Gift gift) async {
    await _dao.update(gift);
  }

  // Delete a gift by its ID
  Future<void> deleteGift(int id) async {
    await _dao.delete(id);
  }

  // Get the first 'n' gifts
  Future<List<Gift>> getFirstGifts(int limit) async {
    return await _dao.getFirstGifts(limit);
  }
}

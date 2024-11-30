import 'dart:typed_data';

class StoreItem {
  final int id;
  final String itemName;
  final int cost;
  final int priceInCents;
  final Uint8List image;

  StoreItem({
    required this.id,
    required this.itemName,
    required this.cost,
    required this.priceInCents,
    required this.image,
  });

  factory StoreItem.fromMap(Map<String, dynamic> map) {
    return StoreItem(
      id: map['id'],
      itemName: map['itemName'],
      cost: map['cost'],
      priceInCents: map['priceInCents'],
      image: map['image'],
    );
  }
}

import 'package:latlong2/latlong.dart' as latlong2;

class PostedAd {
  final String? id; // شناسه یکتا
  final String title;
  final String category;
  final String subCategory;
  final String price;
  final String city;
  final DateTime postedAt;
  final List<String> images; // base64 encoded images
  final String province;
  final String description;
  final latlong2.LatLng location;
  final List<String> postTypes;

  PostedAd({
    this.id,
    required this.title,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.city,
    required this.postedAt,
    required this.images,
    required this.province,
    required this.description,
    required this.location,
    required this.postTypes,
  });

  // محاسبه زمان گذشته
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postedAt);

    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ماه پیش';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} روز پیش';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعت پیش';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقیقه پیش';
    } else {
      return 'همین حالا';
    }
  }

  // تبدیل به Map برای ذخیره/ارسال
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'city': city,
      'postedAt': postedAt.toIso8601String(),
      'images': images,
      'province': province,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'postTypes': postTypes,
    };
  }

  // ایجاد از Map
  factory PostedAd.fromMap(Map<String, dynamic> map) {
    return PostedAd(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      subCategory: map['subCategory'],
      price: map['price'],
      city: map['city'],
      postedAt: DateTime.parse(map['postedAt']),
      images: List<String>.from(map['images']),
      province: map['province'],
      description: map['description'],
      location: latlong2.LatLng(
        map['latitude'] ?? 0.0,
        map['longitude'] ?? 0.0,
      ),
      postTypes: List<String>.from(map['postTypes']),
    );
  }
}
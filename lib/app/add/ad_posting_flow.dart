import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:my_apps/app/models/posted_ad.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class AdPostingFlow extends StatelessWidget {
  final void Function(PostedAd) onAdPosted;

  const AdPostingFlow({super.key, required this.onAdPosted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' ثبت اعلانات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: CategorySelectionPage(onAdPosted: onAdPosted),
    );
  }
}

/// مرحله ۱: انتخاب دسته و زیرشاخه
class CategorySelectionPage extends StatelessWidget {
  final void Function(PostedAd) onAdPosted;

  const CategorySelectionPage({super.key, required this.onAdPosted});

  final List<String> categories = const [
    'منازل',
    'وسایل نقلیه',
    'مبایل و کمپیوتر',
    'موارد برقی',
    'کاریابی',
    'اجتماعی',
    'اسباب بازی',
    'خدمات',
    'آشپزخانه',
    'وسایل شخصی',
  ];

  final Map<String, List<String>> subCategories = const {
    'منازل': ['آپارتمان', 'ویلا', 'خانه', 'باغ', 'زمین', 'دوکان'],
    'وسایل نقلیه': ['موتر', 'تیلری', 'ریکشا', 'زرنج', 'موترسکلیت'],
    'مبایل و کمپیوتر': ['موبایل', 'لپ تاپ', 'تبلت', 'کمپیوتر رومیزی'],
    'موارد برقی': ['یخچال', 'تلویزیون', 'ماشین لباسشویی', 'مایکروویو'],
    'کاریابی': ['اداری', 'فنی', 'خدماتی', 'حرفه‌ای'],
    'اجتماعی': ['رویدادها', 'گروه‌ها', 'فعالیت‌ها'],
    'اسباب بازی': ['پسرانه', 'دخترانه', 'آموزشی'],
    'خدمات': ['رستوران', 'کافی شاپ', 'حمل و نقل'],
    'آشپزخانه': ['ظروف', 'لوازم آشپزی', 'دکوری'],
    'وسایل شخصی': ['ساعت', 'عینک', 'زیورآلات'],
  };

  final Map<String, List<String>> postTypes = const {
    'منازل': ['برای فروش', 'برای کرایی', 'برای گرویی'],
    'وسایل نقلیه': ['برای فروش', 'برای کرایی'],
    'مبایل و کمپیوتر': ['برای فروش', 'برای تعویض'],
    'موارد برقی': ['برای فروش', 'برای تعمیر'],
    'کاریابی': ['دائمی', 'موقت', 'پاره وقت'],
    'اجتماعی': ['رایگان', 'با هزینه'],
    'اسباب بازی': ['برای فروش', 'هدیه'],
    'خدمات': ['رایگان', 'با هزینه'],
    'آشپزخانه': ['برای فروش', 'هدیه'],
    'وسایل شخصی': ['برای فروش', 'تعویض'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 دسته ها'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final subs = subCategories[cat] ?? [];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                cat,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                for (var sub in subs)
                  ListTile(
                    title: Text(sub),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      _showPostTypeBottomSheet(
                        context,
                        cat,
                        sub,
                        postTypes[cat] ?? [],
                      );
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('➕ سایر...'),
                  onTap: () {
                    _showPostTypeBottomSheet(
                      context,
                      cat,
                      'سایر',
                      postTypes[cat] ?? [],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPostTypeBottomSheet(
    BuildContext context,
    String category,
    String subCategory,
    List<String> types,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PostTypeSelector(
        category: category,
        subCategory: subCategory,
        types: types,
        isCustom: subCategory == 'سایر',
        onAdPosted: onAdPosted,
      ),
    );
  }
}

/// مرحله ۲: انتخاب نوع آگهی
class PostTypeSelector extends StatefulWidget {
  final String category;
  final String subCategory;
  final List<String> types;
  final bool isCustom;
  final void Function(PostedAd) onAdPosted;

  const PostTypeSelector({
    super.key,
    required this.category,
    required this.subCategory,
    required this.types,
    this.isCustom = false,
    required this.onAdPosted,
  });

  @override
  State<PostTypeSelector> createState() => _PostTypeSelectorState();
}

class _PostTypeSelectorState extends State<PostTypeSelector> {
  final List<String> selectedTypes = [];
  final TextEditingController customSubController = TextEditingController();

  @override
  void dispose() {
    customSubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + keyboardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isCustom
                ? 'نام جدید را وارد کنید'
                : 'نوع اعلان: ${widget.subCategory}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          if (widget.isCustom)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TextField(
                controller: customSubController,
                decoration: InputDecoration(
                  labelText: 'نام زیرشاخه دلخواه',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 10),
          
          Wrap(
            spacing: 8,
            children: widget.types.map((type) {
              final isSelected = selectedTypes.contains(type);
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) => setState(() {
                  if (selected) {
                    selectedTypes.add(type);
                  } else {
                    selectedTypes.remove(type);
                  }
                }),
                selectedColor: Colors.teal.shade100,
                checkmarkColor: Colors.teal,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('تأیید و ادامه'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              final subCategory = widget.isCustom
                  ? (customSubController.text.isEmpty 
                      ? 'نام دلخواه' 
                      : customSubController.text)
                  : widget.subCategory;
              
              Navigator.of(context).pop();
              
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostCreationScreen(
                    category: widget.category,
                    subCategory: subCategory,
                    postTypes: selectedTypes,
                    onAdPosted: widget.onAdPosted,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PostCreationScreen extends StatefulWidget {
  final String category;
  final String subCategory;
  final List<String> postTypes;
  final void Function(PostedAd) onAdPosted;

  const PostCreationScreen({
    super.key,
    required this.category,
    required this.subCategory,
    required this.postTypes,
    required this.onAdPosted,
  });

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final List<Uint8List> _images = [];
  final ImagePicker _picker = ImagePicker();
  latlong2.LatLng? _selectedLocation;
  String? _province, _city;
  final MapController _mapController = MapController();
  bool _isMapVisible = false;

  final Map<String, List<String>> _cities = {
    'کابل': ['ناحیه ۱', 'چاریکار'],
    'هرات': ['هرات شهر', 'اسلام قلعه'],
    'بلخ': ['مزارشریف', 'شولگره'],
    'ننگرهار': ['جلال آباد', 'حصارک'],
  };

  int? _beds, _baths, _size, _parking;
  String _notes = '';
  String _article1 = '';
  String _article2 = '';
  double _price = 0.0;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      for (final image in images) {
        if (_images.length >= 3) break;
        final bytes = await image.readAsBytes();
        setState(() => _images.add(bytes));
      }
      if (_images.length > 3) {
        _images.removeRange(3, _images.length);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در انتخاب عکس: ${e.toString()}')),
      );
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return null;
        }
      }
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  Future<void> _moveToCurrentLocation() async {
    final position = await _getCurrentLocation();
    if (position != null) {
      final location = latlong2.LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = location;
        _isMapVisible = true;
      });
      _mapController.move(location, 14);
    }
  }

  void _openInMapApp() async {
    if (_selectedLocation != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${_selectedLocation!.latitude},${_selectedLocation!.longitude}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نمی‌توان نقشه را باز کرد')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} > ${widget.subCategory}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text(
              'تصاویر (حداکثر ۳ عکس)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var imageBytes in _images)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Stack(
                      children: [
                        Image.memory(
                          imageBytes,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() => _images.remove(imageBytes));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_images.length < 3)
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('افزودن عکس'),
                        content: const Text('منبع عکس را انتخاب کنید'),
                        actions: [
                          TextButton(
                            child: const Text('دوربین'),
                            onPressed: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          TextButton(
                            child: const Text('گالری'),
                            onPressed: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'قیمت گذاری',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'قیمت (افغانی)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _price = double.tryParse(value) ?? 0.0,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً قیمت را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'مکان دقیق',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _moveToCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade100,
                foregroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: 8),
                  Text(
                    _selectedLocation == null
                        ? 'انتخاب موقعیت روی نقشه'
                        : 'موقعیت انتخاب شده',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            if (_isMapVisible && _selectedLocation != null)
              Column(
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _selectedLocation!,
                        zoom: 14,
                        onTap: (_, latlong2.LatLng location) {
                          setState(() => _selectedLocation = location);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'raminayobi001@gmail.com',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              builder: (ctx) => GestureDetector(
                                onTap: _openInMapApp,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            const Text(
              'ولایت/شهر',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'ولایت',
                border: OutlineInputBorder(),
              ),
              value: _province,
              items: _cities.keys.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(province),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _province = value;
                  _city = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً ولایت را انتخاب کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'شهر',
                border: OutlineInputBorder(),
              ),
              value: _city,
              items: (_province == null
                  ? <String>[]
                  : _cities[_province]!).map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _city = value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً شهر را انتخاب کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'مقاله ۱',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'متن مقاله اول را اینجا وارد کنید',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => _article1 = value,
            ),
            const SizedBox(height: 12),
            const Text(
              'مقاله ۲',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'متن مقاله دوم را اینجا وارد کنید',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => _article2 = value,
            ),
            const SizedBox(height: 16),
            const Text(
              'امکانات / توضیحات',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.category == 'منازل') ...[
              _buildNumberField('تعداد تخت', (value) => _beds = value),
              _buildNumberField('حمام', (value) => _baths = value),
              _buildNumberField('متراژ', (value) => _size = value),
              _buildNumberField('پارکینگ', (value) => _parking = value),
            ] else ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'توضیحات',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onChanged: (value) => _notes = value,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitToLaravel,
                child: const Text('ارسال برای برسی '),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, Function(int?) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) => onSaved(int.tryParse(value)),
      ),
    );
  }

  void _submitToLaravel() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفاً موقعیت مکانی را انتخاب کنید')),
        );
        return;
      }

      final postedAd = PostedAd(
        title: widget.subCategory,
        category: widget.category,
        subCategory: widget.subCategory,
        price: _price.toStringAsFixed(0),
        city: _city ?? '',
        postedAt: DateTime.now(),
        images: _images.map((e) => base64Encode(e)).toList(),
        province: _province ?? '',
        description: _notes,
        location: _selectedLocation!,
        postTypes: widget.postTypes,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('در حال ارسال به برسی...'),
            ],
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ارسال موفق'),
            content: const Text('اطلاعات اعلان با موفقیت به مدریت ارسال شد.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  widget.onAdPosted(postedAd);
                },
                child: const Text('تمام'),
              ),
            ],
          ),
        );
      });
    }
  }
}
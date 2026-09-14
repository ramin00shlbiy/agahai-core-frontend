import 'package:flutter/material.dart';
import 'package:my_apps/app/add/ad_posting_flow.dart';
import 'package:my_apps/app/models/posted_ad.dart';
import 'package:latlong2/latlong.dart' as latlong2;
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF25ADDD),
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _citySearchController = TextEditingController();

  int _selectedIndex = 0;
  String? _selectedSub;
  List<String> _selectedCities = ['کابل'];
  String _searchQuery = '';
  String _citySearchQuery = '';
  final List<String> _savedAds = [];

  final List<Category> _categories = [
    Category('منازل', Icons.home, ['خانه', 'ویلا', 'آپارتمان']),
    Category('وسایل نقلیه', Icons.directions_car, ['ماشین', 'موتور', 'کامیون']),
    Category('مبایل و کامپیوتر', Icons.phone_android, ['موبایل', 'لپ تاپ', 'تبلت']),
    Category('موارد برقی', Icons.lightbulb, ['یخچال', 'تلویزیون', 'ماشین لباسشویی']),
    Category('کاریابی', Icons.work, ['اداری', 'فنی', 'خدماتی']),
    Category('اجتماع', Icons.people, ['رویدادها', 'گروه ها', 'فعالیت ها']),
    Category('اسباب بازی', Icons.games, ['پسرانه', 'دخترانه', 'آموزشی']),
    Category('خدمات', Icons.restaurant, ['رستوران', 'کافی شاپ', 'حمل و نقل']),
    Category('خانه آشپزخانه', Icons.kitchen, ['ظروف', 'لوازم آشپزی', 'دکوری']),
    Category('وسایل شخصی', Icons.watch, ['ساعت', 'عینک', 'زیورآلات']),
  ];

  final List<Product> _products = [
    Product('خانه لوکس در کابل', 'منازل', '5,000,000', 'خانه', '2 ساعت پیش', 'کابل', []),
    Product('ویلا در شمال کابل', 'منازل', '12,000,000', 'ویلا', '5 ساعت پیش', 'کابل', []),
    Product('آپارتمان مدرن', 'منازل', '3,500,000', 'آپارتمان', '1 روز پیش', 'کابل', []),
    Product('تویوتا کورولا 2020', 'وسایل نقلیه', '2,500,000', 'ماشین', '3 ساعت پیش', 'هرات', []),
    Product('موتور هوندا', 'وسایل نقلیه', '450,000', 'موتور', '6 ساعت پیش', 'مزار شریف', []),
    Product('یخچال سامسونگ', 'خانه آشپزخانه', '1,200,000', 'یخچال', '1 روز پیش', 'کابل', []),
    Product('موبایل سامسونگ S22', 'مبایل و کامپیوتر', '800,000', 'موبایل', '4 ساعت پیش', 'هرات', []),
    Product('لپ تاپ دل', 'مبایل و کامپیوتر', '1,500,000', 'لپ تاپ', '2 روز پیش', 'کابل', []),
    Product('میز ناهارخوری چوبی', 'خانه آشپزخانه', '350,000', 'دکوری', '8 ساعت پیش', 'مزار شریف', []),
    Product('دستبند طلا 18 عیار', 'وسایل شخصی', '1,850,000', 'زیورآلات', '1 روز پیش', 'کابل', []),
  ];

  void _addPostedAd(PostedAd ad) {
    setState(() {
      _products.add(Product(
        ad.title,
        ad.category,
        ad.price,
        ad.subCategory,
        ad.timeAgo,
        ad.city,
        ad.postTypes,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اعلان شما با موفقیت اضافه شد'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _onNavTap(int index) {
    if (index == 4) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else if (index == 0 && _selectedIndex == 0) {
      _resetFilter();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AdPostingFlow(
            onAdPosted: _addPostedAd,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _resetFilter() => setState(() {
        _selectedSub = null;
        _searchQuery = '';
        _searchController.clear();
      });

  List<Product> get _filtered {
    List<Product> filtered = _products;
    
    if (_selectedSub != null) {
      filtered = filtered.where((p) => p.subCategory == _selectedSub).toList();
    }
    
    if (_selectedCities.isNotEmpty) {
      filtered = filtered.where((p) => _selectedCities.contains(p.city)).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.title.contains(_searchQuery) || 
        p.category.contains(_searchQuery) ||
        p.subCategory.contains(_searchQuery)
      ).toList();
    }
    
    if (_selectedIndex == 1) {
      filtered = filtered.where((p) => _savedAds.contains(p.title)).toList();
    }
    
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
    _citySearchController.addListener(() {
      setState(() => _citySearchQuery = _citySearchController.text);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _citySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filtered;
    final primaryColor = Theme.of(context).primaryColor;
    
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: _buildDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: _buildSearchBar(),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedIndex != 1) _buildCategoryList(),
            if (_selectedSub != null || _searchQuery.isNotEmpty) _buildActiveFilters(),
            Expanded(
              child: filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : _buildProductList(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  _selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined,
                  size: 24,
                ),
              ),
              label: 'صفحه اصلی',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  _selectedIndex == 1 ? Icons.bookmark : Icons.bookmark_border,
                  size: 24,
                ),
              ),
              label: 'ذخیره‌ها',
            ),
BottomNavigationBarItem(
  icon: Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).primaryColor,
    ),
    child: const Icon(Icons.add, size: 24, color: Colors.white),
  ),
  label: 'ثبت اعلانات',
),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  _selectedIndex == 3 ? Icons.forum : Icons.forum_outlined,
                  size: 24,
                ),
              ),
              label: 'پیام‌ها',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  _selectedIndex == 4 ? Icons.menu : Icons.menu_open,
                  size: 24,
                ),
              ),
              label: 'بخش‌ها',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'حساب کاربری',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ...['ثبت هویت', 'بازدیدهای اخیر', 'تنظیمات', 'پشتیبانی'].map(
              (t) => ListTile(
                leading: const Icon(Icons.chevron_right),
                title: Text(t),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );

  Widget _buildSearchBar() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          InkWell(
            onTap: _showCityDialog,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.blue),
                  const SizedBox(width: 4),
                  if (_selectedCities.isEmpty)
                    const Text(
                      'ولاایات',
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (_selectedCities.length == 1)
                    Text(
                      _selectedCities[0],
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_selectedCities.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'ولایت',
                          style: TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'جستجواعلانات درآگاهی‌',
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _resetFilter,
                      )
                    : null,
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCityDialog() {
    List<String> tempSelected = List.from(_selectedCities);
    _citySearchController.clear();
    _citySearchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'انتخاب ولایات',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _citySearchController,
                      decoration: InputDecoration(
                        hintText: 'جستجوی ولایت...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _citySearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _citySearchController.clear();
                                  setModalState(() => _citySearchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => setModalState(() => _citySearchQuery = value),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: _getFilteredCities().map((city) => CheckboxListTile(
                          title: Text(city),
                          value: tempSelected.contains(city),
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                tempSelected.add(city);
                              } else {
                                tempSelected.remove(city);
                              }
                            });
                          },
                        )).toList(),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text('بازنشانی'),
                            onPressed: () => setModalState(() => tempSelected.clear()),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _selectedCities = tempSelected);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('تأیید', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _getFilteredCities() {
    List<String> cities = [
      'کابل', 'هرات', 'مزار شریف', 'قندهار', 'جلال آباد',
      'غزنی', 'پکتیا', 'بدخشان', 'فراه', 'هلمند'
    ];
    
    if (_citySearchQuery.isEmpty) return cities;
    
    return cities
        .where((city) => city.contains(_citySearchQuery))
        .toList();
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children: [
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _showTopFilterDialog(context, cat),
                    customBorder: const CircleBorder(),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(cat.icon, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTopFilterDialog(BuildContext context, Category category) {
    String? tempSelected = _selectedSub;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              margin: const EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'انتخاب نوع ${category.title}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: category.subs.map((s) {
                            final sel = s == tempSelected;
                            return ChoiceChip(
                              label: Text(s),
                              selected: sel,
                              selectedColor: Theme.of(context).primaryColor,
                              onSelected: (_) {
                                setModalState(() => tempSelected = sel ? null : s);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _selectedSub = tempSelected);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('تأیید', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedSub != null)
            Chip(
              label: Text(_selectedSub!),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => setState(() => _selectedSub = null),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          if (_searchQuery.isNotEmpty)
            Chip(
              label: Text('جستجو: $_searchQuery'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: _resetFilter,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          if (_selectedCities.isNotEmpty)
            ..._selectedCities.map((city) => Chip(
                  label: Text(city),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _selectedCities.remove(city));
                  },
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedIndex == 1 ? Icons.bookmark_border : Icons.search_off,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedIndex == 1 ? 'موردی ذخیره نشده است' : 'اعلان یافت نشد',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final p = _filtered[i];
        final isSaved = _savedAds.contains(p.title);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // عملکرد کلیک روی کارت
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${p.price} افغانی',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.category,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.subCategory,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(p.city, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(p.timeAgo, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? Theme.of(context).primaryColor : Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                if (isSaved) {
                                  _savedAds.remove(p.title);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('از ذخیره‌ها حذف شد'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).size.height - 150,
                                        left: 10,
                                        right: 10,
                                      ),
                                    ),
                                  );
                                } else {
                                  _savedAds.add(p.title);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('ذخیره شد'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).size.height - 150,
                                        left: 10,
                                        right: 10,
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.grey[600]),
                            onPressed: () {
                              // عملکرد اشتراک گذاری
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Category {
  final String title;
  final IconData icon;
  final List<String> subs;
  Category(this.title, this.icon, this.subs);
}

class Product {
  final String title, category, price, subCategory, timeAgo, city;
  final List<String> postTypes;
  Product(this.title, this.category, this.price, this.subCategory, this.timeAgo, this.city, this.postTypes);
}
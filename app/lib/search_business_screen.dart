import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'constants.dart';
import 'business_detail_screen.dart';

class SearchBusinessScreen extends StatefulWidget {
  const SearchBusinessScreen({super.key});

  @override
  State<SearchBusinessScreen> createState() => _SearchBusinessScreenState();
}

class _SearchBusinessScreenState extends State<SearchBusinessScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Name';
  List<String> _filters = ['Name', 'GSTIN', 'PAN', 'Mobile'];
  bool _isSearching = false;

  // Mock data for search results
  final List<Map<String, dynamic>> _mockBusinesses = [
    {
      'lgnm': 'SRI SHANKER VIJAYA SAW MILLS',
      'tradeNam': 'SRI SHANKER VIJAYA SAW MILLS',
      'gstin': '33AABFS0153K1ZH',
      'ctb': 'Partnership',
      'rgdt': '01/07/2017',
      'dty': 'Regular',
      'sts': 'Active',
      'pradr':
          'OLD 195/ NEW 335, SYDENHAMS ROAD, APPARAO GARDEN, CHOOLAI, Chennai, Tamil Nadu, 600112',
      'nba': [
        'Office Sale Office',
        'Retail Business',
        'Wholesale Business',
        'Warehouse epot',
        'Others',
      ],
      'stj':
          'State - Tamil Nadu, Division - CHENNAI NORTH, Zone - North-III, Circle - CHOOLAI',
      'ctj':
          'State - CBIC, Zone - CHENNAI, Commissionerate - CHENNAI-NORTH, Division - PARRYS, Range - RANGE V',
      'adhrVFlag': 'Yes',
      'adhrVdt': '24/04/2025',
      'ekycVFlag': 'Not Applicable',
      'einvoiceStatus': 'No',
      'isFieldVisitConducted': 'No',
    },
    {
      'lgnm': 'TECH INNOVATORS PVT LTD',
      'tradeNam': 'TECH INNOVATORS',
      'gstin': '29AADCT1234P1ZR',
      'ctb': 'Private Limited Company',
      'rgdt': '15/03/2018',
      'dty': 'Regular',
      'sts': 'Active',
      'pradr': '42, ELECTRONICS CITY, PHASE II, Bengaluru, Karnataka, 560100',
      'nba': [
        'IT Services',
        'Software Development',
        'Consultancy',
        'E-commerce',
      ],
      'stj':
          'State - Karnataka, Division - BANGALORE SOUTH, Zone - East, Circle - ELECTRONICS CITY',
      'ctj':
          'State - CBIC, Zone - BANGALORE, Commissionerate - BANGALORE-EAST, Division - E-CITY, Range - RANGE II',
      'adhrVFlag': 'Yes',
      'adhrVdt': '10/05/2025',
      'ekycVFlag': 'Yes',
      'einvoiceStatus': 'Yes',
      'isFieldVisitConducted': 'Yes',
    },
    {
      'lgnm': 'GLOBAL EXPORTS INDIA LTD',
      'tradeNam': 'GLOBAL EXPORTS',
      'gstin': '27AAECG7890Q1Z1',
      'ctb': 'Public Limited Company',
      'rgdt': '22/08/2017',
      'dty': 'Regular',
      'sts': 'Active',
      'pradr':
          'PLOT 78, MIDC INDUSTRIAL AREA, ANDHERI EAST, Mumbai, Maharashtra, 400093',
      'nba': ['Export of Goods', 'Import of Goods', 'Trading', 'Manufacturing'],
      'stj':
          'State - Maharashtra, Division - MUMBAI EAST, Zone - Central, Circle - ANDHERI',
      'ctj':
          'State - CBIC, Zone - MUMBAI, Commissionerate - MUMBAI-CENTRAL, Division - ANDHERI, Range - RANGE III',
      'adhrVFlag': 'Yes',
      'adhrVdt': '15/09/2023',
      'ekycVFlag': 'Yes',
      'einvoiceStatus': 'Yes',
      'isFieldVisitConducted': 'Yes',
    },
    {
      'lgnm': 'SUNSHINE PHARMACEUTICALS PVT LTD',
      'tradeNam': 'SUNSHINE PHARMA',
      'gstin': '24AADCS5678Q1Z0',
      'ctb': 'Private Limited Company',
      'rgdt': '05/09/2017',
      'dty': 'Regular',
      'sts': 'Active',
      'pradr': 'PLOT 45, GIDC, INDUSTRIAL ESTATE, VADODARA, Gujarat, 390010',
      'nba': [
        'Manufacturing of Drugs',
        'Wholesale Business',
        'R&D Services',
        'Export of Goods',
      ],
      'stj':
          'State - Gujarat, Division - VADODARA EAST, Zone - North, Circle - GIDC',
      'ctj':
          'State - CBIC, Zone - VADODARA, Commissionerate - VADODARA-I, Division - EAST, Range - RANGE I',
      'adhrVFlag': 'Yes',
      'adhrVdt': '30/03/2024',
      'ekycVFlag': 'Yes',
      'einvoiceStatus': 'Yes',
      'isFieldVisitConducted': 'Yes',
    },
    {
      'lgnm': 'EASTERN ENTERPRISES',
      'tradeNam': 'EASTERN TRADE',
      'gstin': '19AABCE7890S1ZR',
      'ctb': 'Proprietorship',
      'rgdt': '12/10/2017',
      'dty': 'Regular',
      'sts': 'Active',
      'pradr': '45 GARIAHAT ROAD, BALLYGUNGE, Kolkata, West Bengal, 700019',
      'nba': ['Retail Business', 'Wholesale Business', 'Trading'],
      'stj':
          'State - West Bengal, Division - KOLKATA SOUTH, Zone - South, Circle - BALLYGUNGE',
      'ctj':
          'State - CBIC, Zone - KOLKATA, Commissionerate - KOLKATA-SOUTH, Division - CENTRAL, Range - RANGE IV',
      'adhrVFlag': 'Yes',
      'adhrVdt': '14/11/2024',
      'ekycVFlag': 'Not Applicable',
      'einvoiceStatus': 'No',
      'isFieldVisitConducted': 'No',
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchResults = List.from(_mockBusinesses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = List.from(_mockBusinesses);
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;

      // Filter based on selected criteria
      switch (_selectedFilter) {
        case 'Name':
          _searchResults =
              _mockBusinesses
                  .where(
                    (business) =>
                        business['lgnm'].toString().toLowerCase().contains(
                          query.toLowerCase(),
                        ) ||
                        business['tradeNam'].toString().toLowerCase().contains(
                          query.toLowerCase(),
                        ),
                  )
                  .toList();
          break;
        case 'GSTIN':
          _searchResults =
              _mockBusinesses
                  .where(
                    (business) => business['gstin']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList();
          break;
        case 'PAN':
          // Extract PAN from GSTIN (characters 3-12)
          _searchResults =
              _mockBusinesses.where((business) {
                String gstin = business['gstin'];
                if (gstin.length >= 12) {
                  String pan = gstin.substring(2, 12);
                  return pan.toLowerCase().contains(query.toLowerCase());
                }
                return false;
              }).toList();
          break;
        case 'Mobile':
          // This is a mock implementation as we don't have mobile numbers in our mock data
          _searchResults =
              _mockBusinesses
                  .where(
                    (business) => business['lgnm']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList();
          break;
      }

      // Simulate a delay in searching
      Future.delayed(AppDurations.fast, () {
        setState(() {
          _isSearching = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search field with filter dropdown
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search business...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.googleBlue,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: const BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: const BorderSide(color: AppColors.googleBlue),
                  ),
                ),
                onChanged: _performSearch,
              ),

              // Filter options
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = filter == _selectedFilter;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8, top: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.googleBlue.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? AppColors.googleBlue
                                  : AppColors.darkGrey,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColors.googleBlue
                                    : AppColors.lightGrey,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
                              _performSearch(_searchController.text);
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Search results section
        _isSearching
            ? const Expanded(child: Center(child: CircularProgressIndicator()))
            : _searchResults.isEmpty
            ? Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.mediumGrey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No businesses found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try a different search term or filter',
                      style: TextStyle(
                        color: AppColors.darkGrey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
            : Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final business = _searchResults[index];
                  return _buildBusinessCard(business);
                },
              ),
            ),
      ],
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    return FadeInUp(
      duration: AppDurations.fast,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BusinessDetailScreen(businessData: business),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      business['sts'] == 'Active'
                          ? AppColors.googleGreen.withOpacity(0.1)
                          : AppColors.googleRed.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.medium),
                    topRight: Radius.circular(AppRadius.medium),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        business['tradeNam'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            business['sts'] == 'Active'
                                ? AppColors.googleGreen.withOpacity(0.2)
                                : AppColors.googleRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text(
                        business['sts'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              business['sts'] == 'Active'
                                  ? AppColors.googleGreen
                                  : AppColors.googleRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Business details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (business['lgnm'] != business['tradeNam'])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Legal Name: ${business['lgnm']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                    Text('GSTIN: ${business['gstin']}'),
                    const SizedBox(height: 8),

                    Text(
                      'Address: ${business['pradr']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 8),

                    // Nature of Business
                    Text(
                      'Nature of Business: ${business['nba'].take(2).join(', ')}${business['nba'].length > 2 ? '...' : ''}',
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.mediumGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Registered on: ${business['rgdt']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.googleBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

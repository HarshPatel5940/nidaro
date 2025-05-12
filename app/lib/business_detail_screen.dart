import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'constants.dart';

class BusinessDetailScreen extends StatefulWidget {
  final Map<String, dynamic> businessData;

  const BusinessDetailScreen({super.key, required this.businessData});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  bool _showAllReports = false;
  final int _reportsPerPage = 3;
  final List<Map<String, dynamic>> _mockReports = [
    {
      'id': 'RPT001',
      'title': 'Financial Discrepancy',
      'description': 'Suspected misreporting of financial transactions.',
      'status': 'Verified',
      'date': '21 Apr 2025',
      'reporter': 'ABC Financial Services',
    },
    {
      'id': 'RPT002',
      'title': 'Incomplete Documentation',
      'description': 'Missing business transaction records for Q1 2025.',
      'status': 'Unverified',
      'date': '15 Apr 2025',
      'reporter': 'Tax Department',
    },
    {
      'id': 'RPT003',
      'title': 'Address Verification',
      'description': 'Business address confirmed during site visit.',
      'status': 'Verified',
      'date': '02 Apr 2025',
      'reporter': 'Registration Authority',
    },
    {
      'id': 'RPT004',
      'title': 'Tax Filing Issue',
      'description': 'Inconsistencies found in recent tax filings.',
      'status': 'Verified',
      'date': '28 Mar 2025',
      'reporter': 'Tax Department',
    },
    {
      'id': 'RPT005',
      'title': 'Product Compliance',
      'description': 'Passed quality standards check for exported goods.',
      'status': 'Verified',
      'date': '15 Mar 2025',
      'reporter': 'Standards Bureau',
    },
    {
      'id': 'RPT006',
      'title': 'Employment Records',
      'description': 'Successfully verified employee count and records.',
      'status': 'Verified',
      'date': '05 Mar 2025',
      'reporter': 'Labor Department',
    },
  ];

  List<Map<String, dynamic>> get _visibleReports {
    final filteredReports =
        _mockReports.where((report) => report['status'] == 'Verified').toList();

    if (_showAllReports) {
      return filteredReports;
    }

    return filteredReports.take(_reportsPerPage).toList();
  }

  @override
  Widget build(BuildContext context) {
    // For full mock data we'll add extra fields that weren't in the card
    Map<String, dynamic> fullBusinessData = {
      ...widget.businessData,
      // Only add missing fields, don't override existing ones
      'tradeNam':
          widget.businessData['tradeNam'] ?? widget.businessData['lgnm'],
      'ctb': widget.businessData['ctb'] ?? 'Partnership',
      'rgdt': widget.businessData['rgdt'] ?? '01/07/2017',
      'dty': widget.businessData['dty'] ?? 'Regular',
      'stj':
          widget.businessData['stj'] ??
          'State - Tamil Nadu, Division - CHENNAI NORTH, Zone - North-III, Circle - CHOOLAI',
      'ctj':
          widget.businessData['ctj'] ??
          'State - CBIC, Zone - CHENNAI, Commissionerate - CHENNAI-NORTH, Division - PARRYS, Range - RANGE V',
      'adhrVFlag': widget.businessData['adhrVFlag'] ?? 'Yes',
      'adhrVdt': widget.businessData['adhrVdt'] ?? '24/04/2025',
      'ekycVFlag': widget.businessData['ekycVFlag'] ?? 'Not Applicable',
      'einvoiceStatus': widget.businessData['einvoiceStatus'] ?? 'No',
      'isFieldVisitConducted':
          widget.businessData['isFieldVisitConducted'] ?? 'No',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBusinessDetails(fullBusinessData),
          const SizedBox(height: 24),
          _buildReportsSection(),
        ],
      ),
    );
  }

  Widget _buildBusinessDetails(Map<String, dynamic> business) {
    return FadeInUp(
      duration: AppDurations.fast,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(AppColors.kAlpha5Percent),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.googleBlue,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailItem('Legal Name (lgnm)', business['lgnm']),
            _buildDetailItem('Trade Name (tradeNam)', business['tradeNam']),
            _buildDetailItem('GSTIN (gstin)', business['gstin']),
            _buildDetailItem('Constitution of Business (ctb)', business['ctb']),
            _buildDetailItem('Date of Registration (rgdt)', business['rgdt']),
            _buildDetailItem('Taxpayer Type (dty)', business['dty']),
            _buildDetailItem(
              'Status (sts)',
              business['sts'],
              business['sts'] == 'Active'
                  ? AppColors.googleGreen
                  : AppColors.googleRed,
            ),
            _buildDetailItem('Principal Address (pradr)', business['pradr']),

            const SizedBox(height: 16),
            const Text(
              'Nature of Business Activities (nba)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (business['nba'] as List<String>).map((activity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.googleBlue.withAlpha(
                          26,
                        ), // 0.1 opacity = 26 alpha
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: AppColors.googleBlue.withAlpha(
                            77,
                          ), // 0.3 opacity = 77 alpha
                          width: 1,
                        ),
                      ),
                      child: Text(
                        activity,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.googleBlue,
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),
            _buildDetailItem('State Jurisdiction (stj)', business['stj']),
            _buildDetailItem('Central Jurisdiction (ctj)', business['ctj']),
            _buildDetailItem(
              'Aadhaar Verification Flag (adhrVFlag)',
              business['adhrVFlag'],
            ),
            _buildDetailItem(
              'Aadhaar Verification Date (adhrVdt)',
              business['adhrVdt'],
            ),
            _buildDetailItem(
              'e-KYC Verification Flag (ekycVFlag)',
              business['ekycVFlag'],
            ),
            _buildDetailItem(
              'e-Invoice Status (einvoiceStatus)',
              business['einvoiceStatus'],
            ),
            _buildDetailItem(
              'Is Field Visit Conducted (isFieldVisitConducted)',
              business['isFieldVisitConducted'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Verified Reports',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.googleBlue,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Show report business bottom sheet
                _showReportBusinessSheet();
              },
              icon: const Icon(
                Icons.flag_outlined,
                color: AppColors.googleRed,
                size: 18,
              ),
              label: const Text(
                'Report Business',
                style: TextStyle(
                  color: AppColors.googleRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Reports list
        ..._visibleReports.map((report) => _buildReportCard(report)),

        // Show all reports button
        if (_mockReports
                .where((report) => report['status'] == 'Verified')
                .length >
            _reportsPerPage)
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllReports = !_showAllReports;
                });
              },
              child: Text(
                _showAllReports ? 'Show Less' : 'Show All Reports',
                style: const TextStyle(
                  color: AppColors.googleBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return FadeInUp(
      duration: AppDurations.fast,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(AppColors.kAlpha5Percent),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
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
                        report['status'] == 'Verified'
                            ? AppColors.googleGreen.withAlpha(
                              26,
                            ) // 0.1 opacity = 26 alpha
                            : AppColors.googleYellow.withAlpha(
                              26,
                            ), // 0.1 opacity = 26 alpha
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    report['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          report['status'] == 'Verified'
                              ? AppColors.googleGreen
                              : AppColors.googleYellow,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report['description'],
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'By: ${report['reporter']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
                Text(
                  report['date'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReportBusinessSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return _ReportBusinessForm(
                scrollController: scrollController,
                businessName: widget.businessData['lgnm'],
                gstin: widget.businessData['gstin'],
              );
            },
          ),
    );
  }
}

class _ReportBusinessForm extends StatefulWidget {
  final ScrollController scrollController;
  final String businessName;
  final String gstin;

  const _ReportBusinessForm({
    required this.scrollController,
    required this.businessName,
    required this.gstin,
  });

  @override
  State<_ReportBusinessForm> createState() => _ReportBusinessFormState();
}

class _ReportBusinessFormState extends State<_ReportBusinessForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Financial';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Financial',
    'Documentation',
    'Address',
    'Tax',
    'Product',
    'Employment',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate report submission
      Future.delayed(AppDurations.medium, () {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });

        // Show success message and close the sheet
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: AppColors.googleGreen,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Business',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                controller: widget.scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Text(
                    'Business: ${widget.businessName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'GSTIN: ${widget.gstin}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Report category
                  const Text(
                    'Report Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Chip(
                              label: Text(category),
                              backgroundColor:
                                  isSelected
                                      ? AppColors.googleBlue.withOpacity(0.1)
                                      : AppColors.lightGrey,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? AppColors.googleBlue
                                        : Colors.black87,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? AppColors.googleBlue
                                        : Colors.transparent,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Report title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Report Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Report description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Provide details about the issue...',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.length < 20) {
                        return 'Description must be at least 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.googleBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Submit Report',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: const Text(
                      'Note: False reporting may lead to legal actions. Please ensure all information provided is accurate to the best of your knowledge.',
                      style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'constants.dart';
import 'color_utils.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _myReports = [
    {
      'id': 'R1001',
      'businessName': 'Tech Solutions Pvt Ltd',
      'gstin': '29AABCT4321R1ZM',
      'title': 'Missing Tax Document',
      'description':
          'Business has not provided proper documentation for the recent transactions.',
      'status': 'Verified',
      'date': '10 May 2025',
    },
    {
      'id': 'R1002',
      'businessName': 'Global Traders',
      'gstin': '06AAACG1234Z1ZP',
      'title': 'Address Verification',
      'description':
          'The registered address does not match the actual business location.',
      'status': 'Pending',
      'date': '05 May 2025',
    },
    {
      'id': 'R1003',
      'businessName': 'Eastern Enterprises',
      'gstin': '19AABCE7890S1ZR',
      'title': 'Illegal Business Activity',
      'description':
          'Business is operating outside the scope of registered activities.',
      'status': 'Unverified',
      'date': '28 Apr 2025',
    },
    {
      'id': 'R1004',
      'businessName': 'Sunshine Pharmaceuticals',
      'gstin': '24AADCS5678Q1Z0',
      'title': 'Product Quality Issue',
      'description':
          'Substandard pharmaceutical products being sold without proper certification.',
      'status': 'Pending',
      'date': '15 Apr 2025',
    },
  ];

  final List<Map<String, dynamic>> _reportsOnMe = [
    {
      'id': 'RO001',
      'reporterName': 'Tax Authority',
      'title': 'Late Filing of Returns',
      'description':
          'Business has failed to file tax returns for the previous quarter on time.',
      'status': 'Verified',
      'date': '02 May 2025',
    },
    {
      'id': 'RO002',
      'reporterName': 'Consumer Protection Agency',
      'title': 'Customer Complaint',
      'description':
          'Multiple customers have reported issues with product quality and after-sales service.',
      'status': 'Pending',
      'date': '25 Apr 2025',
    },
    {
      'id': 'RO003',
      'reporterName': 'Competitor Business',
      'title': 'Unfair Trade Practice',
      'description':
          'Allegation of predatory pricing and monopolistic behavior in the local market.',
      'status': 'Unverified',
      'date': '18 Apr 2025',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Verified':
        return AppColors.googleGreen;
      case 'Unverified':
        return AppColors.googleRed;
      case 'Pending':
        return AppColors.googleYellow;
      default:
        return AppColors.mediumGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(color: Colors.white),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.googleBlue,
            unselectedLabelColor: AppColors.mediumGrey,
            indicatorColor: AppColors.googleBlue,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [Tab(text: 'My Reports'), Tab(text: 'Reports on Me')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildMyReportsTab(), _buildReportsOnMeTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildMyReportsTab() {
    return _myReports.isEmpty
        ? _buildEmptyState('You haven\'t submitted any reports yet.')
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _myReports.length,
          itemBuilder: (context, index) {
            final report = _myReports[index];
            return _buildReportCard(report, isMyReport: true);
          },
        );
  }

  Widget _buildReportsOnMeTab() {
    return _reportsOnMe.isEmpty
        ? _buildEmptyState('No reports have been filed against your business.')
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _reportsOnMe.length,
          itemBuilder: (context, index) {
            final report = _reportsOnMe[index];
            return _buildReportCard(report, isMyReport: false);
          },
        );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.mediumGrey.withAlpha(ColorUtils.alpha50Percent),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkGrey.withAlpha(ColorUtils.alpha70Percent),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    Map<String, dynamic> report, {
    required bool isMyReport,
  }) {
    return FadeInUp(
      duration: AppDurations.fast,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [ColorUtils.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.googleBlue.withAlpha(ColorUtils.alpha5Percent),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.medium),
                  topRight: Radius.circular(AppRadius.medium),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Report #${report['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        report['status'],
                      ).withAlpha(ColorUtils.alpha10Percent),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      report['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(report['status']),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMyReport) ...[
                    Text(
                      report['businessName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GSTIN: ${report['gstin']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Reported by: ${report['reporterName']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    report['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report['description'],
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${report['date']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showReportDetails(report, isMyReport);
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(Map<String, dynamic> report, bool isMyReport) {
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
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.large),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Report #${report['id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          report['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Text(
                        'Status: ${report['status']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(report['status']),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isMyReport) ...[
                      _buildDetailItem('Business Name', report['businessName']),
                      _buildDetailItem('GSTIN', report['gstin']),
                    ] else ...[
                      _buildDetailItem('Reported By', report['reporterName']),
                    ],

                    _buildDetailItem('Title', report['title']),
                    _buildDetailItem('Description', report['description']),
                    _buildDetailItem('Date Reported', report['date']),

                    const SizedBox(height: 24),
                    const Text(
                      'Report Timeline',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTimelineItem(
                      'Report Submitted',
                      report['date'],
                      true,
                    ),
                    _buildTimelineItem(
                      'Under Review',
                      '${report['date'].split(' ')[0]} ${(int.parse(report['date'].split(' ')[0]) + 2)} ${report['date'].split(' ')[2]}',
                      report['status'] != 'Unverified',
                    ),
                    _buildTimelineItem(
                      'Verification Process',
                      '${report['date'].split(' ')[0]} ${(int.parse(report['date'].split(' ')[0]) + 5)} ${report['date'].split(' ')[2]}',
                      report['status'] == 'Verified',
                    ),
                    _buildTimelineItem(
                      'Report Verified',
                      '${report['date'].split(' ')[0]} ${(int.parse(report['date'].split(' ')[0]) + 7)} ${report['date'].split(' ')[2]}',
                      report['status'] == 'Verified',
                    ),

                    const SizedBox(height: 24),
                    if (isMyReport && report['status'] == 'Pending')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report withdrawn successfully!'),
                              backgroundColor: AppColors.googleGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.googleRed,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Withdraw Report'),
                      ),

                    if (!isMyReport && report['status'] != 'Unverified')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dispute filed successfully!'),
                              backgroundColor: AppColors.googleGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.googleBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Dispute Report'),
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.mediumGrey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, bool isCompleted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isCompleted ? AppColors.googleGreen : AppColors.lightGrey,
                border: Border.all(
                  color:
                      isCompleted ? AppColors.googleGreen : AppColors.lightGrey,
                  width: 2,
                ),
              ),
              child:
                  isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
            ),
            if (title != 'Report Verified')
              Container(
                width: 2,
                height: 30,
                color:
                    isCompleted ? AppColors.googleGreen : AppColors.lightGrey,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? Colors.black87 : AppColors.mediumGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isCompleted ? AppColors.darkGrey : AppColors.mediumGrey,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

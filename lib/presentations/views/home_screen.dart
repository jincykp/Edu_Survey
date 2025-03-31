import 'package:edusurvey/core/theme/colors.dart';
import 'package:edusurvey/data/model/survey_model.dart';
import 'package:edusurvey/presentations/views/user_profile.dart';
import 'package:edusurvey/presentations/widgets/custom_sign_buttons.dart';

import 'package:edusurvey/view_models/survey_provider.dart';
import 'package:edusurvey/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch surveys when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final surveyProvider = Provider.of<SurveyFormProvider>(
        context,
        listen: false,
      );
      surveyProvider.getAllSurveys();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfile()),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AllColors.gradientSecond,
                    radius: 25,
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CustomButton(
              text: 'Add Survey',
              onPressed: () {
                // Navigate to add survey page
                // TODO: Implement navigation to your AddSurveyScreen
              },
              isLoading: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textSize: 14,
              borderRadius: 8,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AllColors.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AllColors.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Scheduled'),
                Tab(text: 'Completed'),
                Tab(text: 'With-held'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSurveyList('Pending'), // For scheduled surveys
                _buildSurveyList('Completed'), // For completed surveys
                _buildSurveyList('Withheld'), // For withheld surveys
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyList(String status) {
    return Consumer<SurveyFormProvider>(
      builder: (context, surveyProvider, child) {
        return FutureBuilder<List<SurveyModel>>(
          future: surveyProvider.getAllSurveys(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading surveys: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No ${status.toLowerCase()} surveys found',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            // Filter surveys by status
            final filteredSurveys =
                snapshot.data!
                    .where((survey) => survey.status == status)
                    .toList();

            if (filteredSurveys.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No ${status.toLowerCase()} surveys found',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Refresh surveys list
                await surveyProvider.getAllSurveys();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSurveys.length,
                itemBuilder: (context, index) {
                  final survey = filteredSurveys[index];
                  final dateFormat = DateFormat('d MMM, yyyy');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AllColors.gradientThird
                                    .withOpacity(0.2),
                                child: Icon(
                                  Icons.description,
                                  color: AllColors.gradientThird,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      survey.surveyName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'URN: ${survey.referenceNumber}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  _handleSurveyAction(value, survey);
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'start',
                                        child: Row(
                                          children: [
                                            Icon(Icons.play_arrow),
                                            SizedBox(width: 8),
                                            Text('Start'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          // Info row with fixed constraints to prevent overflow
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _infoItem(
                                    'Created',
                                    dateFormat.format(survey.dateCreated),
                                    Icons.calendar_today,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _infoItem(
                                    'Start',
                                    dateFormat.format(survey.commencementDate),
                                    Icons.play_circle_outline,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _infoItem(
                                    'Due',
                                    dateFormat.format(survey.dueDate),
                                    Icons.timer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Fixed layout for action buttons with equal sizes
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Get the total available width
                              final totalWidth = constraints.maxWidth;
                              // Calculate button width (total width minus spacing) / 3
                              final buttonWidth = (totalWidth - 16) / 3;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: buttonWidth,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.play_arrow,
                                        size: 16,
                                      ),
                                      label: const Text('Start'),
                                      onPressed: () {
                                        _handleSurveyAction('start', survey);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AllColors.primaryColor,
                                        side: BorderSide(
                                          color: AllColors.primaryColor,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: buttonWidth,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Edit'),
                                      onPressed: () {
                                        _handleSurveyAction('edit', survey);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                        side: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: buttonWidth,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.delete, size: 16),
                                      label: const Text('Delete'),
                                      onPressed: () {
                                        _handleSurveyAction('delete', survey);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  void _handleSurveyAction(String action, SurveyModel survey) {
    final surveyProvider = Provider.of<SurveyFormProvider>(
      context,
      listen: false,
    );

    switch (action) {
      case 'start':
        // TODO: Navigate to Survey Commencement screen
        debugPrint('Starting survey: ${survey.referenceNumber}');
        break;

      case 'edit':
        // TODO: Navigate to edit survey screen
        debugPrint('Editing survey: ${survey.referenceNumber}');
        break;

      case 'delete':
        // Show confirmation dialog before deleting
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Move to Withheld?'),
                content: const Text(
                  'This survey will be moved to the Withheld tab. You can restore it later if needed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Navigator.pop(context);
                      // // Update survey status to Withheld
                      // await surveyProvider.updateSurveyStatus(
                      //   survey.referenceNumber,
                      //   'Withheld',
                      // );
                      // // Refresh the survey list
                      // setState(() {});
                    },
                    child: const Text(
                      'Move',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
        break;
    }
  }
}

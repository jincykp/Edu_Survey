import 'package:edusurvey/core/theme/colors.dart';
import 'package:flutter/material.dart';

class SurveyCommencementPage extends StatelessWidget {
  SurveyCommencementPage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key
      appBar: AppBar(
        title: Text('Survey Commencement'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Open drawer using the key
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'General Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AllColors.primaryColor,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return ListTile(title: Text('Item $index'));
                },
                itemCount: 5,
              ),
            ),
          ],
        ),
      ),
      body: Column(children: [
      
        ],
      ),
    );
  }
}

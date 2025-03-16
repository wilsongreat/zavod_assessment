import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zavod_assessment_app/data/models/map_location_model.dart';
import 'dart:math';
import 'package:zavod_assessment_app/presentation/components/map/map_widget.dart';
import 'package:zavod_assessment_app/presentation/pages/history_page.dart';
import 'package:zavod_assessment_app/presentation/pages/profile.dart';
import 'package:zavod_assessment_app/presentation/pages/support_page.dart';
import 'package:zavod_assessment_app/utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<NavigationRecord> navigationHistory = [];

  final List<MapLocation> mapLocations = List.generate(
    7,
        (index) => MapLocation(
      id: index,
      position: LatLng(
        6.5244 + (Random().nextDouble() - 0.5) * 0.1, // Random positions near NYC
        3.3792 + (Random().nextDouble() - 0.5) * 0.1,
      ),
      title: 'Location: ${index + 1}',
      description: 'This is the description for Location ${index + 1}. Tap to navigate here.',
    ),
  );

  @override
  void initState() {
    super.initState();
    _addNavigationRecord("Home");
  }

  void _addNavigationRecord(String destination) {
    if (navigationHistory.length >= 5) {
      navigationHistory.removeAt(0);
    }

    setState(() {
      navigationHistory.add(
        NavigationRecord(
          from: navigationHistory.isEmpty ? "A" : navigationHistory.last.to,
          to: destination,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.kbg,
        title: const Text('Zavod Test',style: TextStyle(color: AppColors.kWhite),),
        iconTheme: IconThemeData(color: AppColors.kWhite),
      ),
      body: Column(
        children: [
          Expanded(
            child: MapScreen(
              locations: mapLocations,
              onLocationSelected: (location) {
                _addNavigationRecord(location.title);

              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.kbg,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.kWhite,
                  ),
                  Text('Wilson', style: TextStyle(fontSize: 20,color: AppColors.kWhite),)
                ],
              )
            ),
            menuItemTab(label: 'Profile',iconData: Hicons.profile_1_light_outline,onTap: (){
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> ProfilePage()));
            }),
            menuItemTab(label: 'History',iconData: Hicons.location_light_outline,onTap: (){
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> HistoryPage()));
            }),
            menuItemTab(label: 'Support',iconData: Hicons.headphone_2_light_outline,onTap: (){
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> SupportPage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget menuItemTab({
    iconData,
    label,
    onTap,
    navWidget
  }){
    return Column(
      children: [
        ListTile(
          leading:  Icon(iconData, size: 30,color: AppColors.kbg,),
          title:  Text(label),
          onTap: () {
            onTap();
            // _openVerticalMenu(context);
          },
        ),
        Divider(color: AppColors.kbg.withValues(alpha: .2),),

      ],
    );
  }
}



class NavigationRecord {
  final String from;
  final String to;
  final DateTime timestamp;

  NavigationRecord({
    required this.from,
    required this.to,
    required this.timestamp,
  });
}



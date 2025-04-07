// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:solid_auth_example/models/Responsive.dart';
import 'package:solid_auth_example/screens/PublicProfile.dart';

// ignore: must_be_immutable
class PublicScreen extends StatelessWidget {
  String webId;

  PublicScreen({Key? key, required this.webId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navigate to public profile with a loading screen
    var loadingScreen = PublicProfile(webId: webId);
    return Scaffold(
        body: Responsive(
      mobile: loadingScreen,
      tablet: loadingScreen,
      desktop: loadingScreen,
    ));
  }
}

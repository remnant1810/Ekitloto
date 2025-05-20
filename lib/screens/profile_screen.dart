import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../main.dart';
import '../utils/pdf_export.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xff3f729b);
    const Color iconColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: iconColor,
            fontWeight: FontWeight.normal,
            fontFamily: 'Montserrat'
          ),
        ),
        backgroundColor: const Color(0xff1c2331),
      ),
      body: ListView(
        //padding: const EdgeInsets.all(20),
        children:[
          const SizedBox(height: 16),
          // Google Login Card
          SizedBox(
            width: double.infinity,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: ListTile(              
                leading: const Icon(
                  Icons.cloud_upload, color: iconColor
                ),
                title: const Text('Cloud Backup'),
                trailing: const Icon(Icons.chevron_right, color: iconColor),
                onTap: () {}, // TODO: Implement Google login
              ),
            ),
          ),
          const SizedBox(height: 16),
          //Personalisation Settings

          // Security Settings
          SizedBox(
            width: double.infinity,
            child:Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(
                    Icons.lock, color: iconColor),
                    title: Text('Security'),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.fingerprint, color: iconColor
                    ),
                    title: const Text('Finger print'),
                    trailing: Switch(
                      value: false, // TODO: Bind to finger print state
                      onChanged: (val) {},
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.lock, color: iconColor
                    ),
                    title: const Text('Passcode'),
                    trailing: Switch(
                      value: false, // TODO: Bind to passcode state
                      onChanged: (val) {},
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Export Dreams to PDF
          SizedBox(
            width: double.infinity,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: iconColor),
                title: const Text('Export Dreams'),
                trailing: const Icon(Icons.chevron_right, color: iconColor),
                onTap: () async {
                  final box = Hive.box<Dream>('dreams');
                  final dreams = box.values.toList();
                  if (dreams.isEmpty) { 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No dreams to export.'))
                    );
                    return;
                  }
                  await exportDreamsToPdf(dreams);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Language Settings
          SizedBox(
            width: double.infinity,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: ListTile(
                leading: const Icon(Icons.language, color: iconColor),
                title: const Text('Language'),
                subtitle: const Text('Select your preferred language'),
                trailing: const Icon(Icons.chevron_right, color: iconColor),
                onTap: () {}, // TODO: Implement language selection
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Rate Us
          SizedBox(
            width: double.infinity,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: ListTile(
                leading: const Icon(Icons.thumb_up, color: iconColor),
                title: const Text('Rate Us'),
                subtitle: const Text('Rate us on the app store'),
                trailing: const Icon(Icons.chevron_right, color: iconColor),
                onTap: () {}, // TODO: Implement rate us
              ),
            ),
          ),
          // About Us
          SizedBox(
            width: double.infinity,
            child: const Card(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: iconColor),
                title: Text('About Us'),
                subtitle: Text('Dream Journal App v1.0\nCreated by Your Team')
              ),
            ),
          ),
        ],
      ),
    );
  }
}
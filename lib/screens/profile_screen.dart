import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dream_journal/screens/privacy_policy_screen.dart';
import 'package:dream_journal/screens/terms_of_service_screen.dart';
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
                    child: Text(
                      'About Dream Journal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: iconColor),
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                    trailing: IconButton(
                      icon: const Icon(Icons.update, color: Colors.blue),
                      onPressed: () {
                        // TODO: Implement check for updates
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checking for updates...')),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.copyright, color: iconColor),
                    title: const Text('Copyright'),
                    subtitle: const Text('© 2025 Dream Journal Team'),
                    onTap: () {
                      // TODO: Show copyright information
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: iconColor),
                    title: const Text('Privacy Policy'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description, color: iconColor),
                    title: const Text('Terms of Service'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email, color: iconColor),
                    title: const Text('Contact Us'),
                    subtitle: const Text('support@dreamjournal.app'),
                    onTap: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'support@dreamjournal.app',
                        query: 'subject=Dream Journal Support',
                      );
                      
                      try {
                        final url = emailLaunchUri.toString();
                        if (await canLaunchUrl(emailLaunchUri)) {
                          await launchUrl(emailLaunchUri);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not launch email client'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
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
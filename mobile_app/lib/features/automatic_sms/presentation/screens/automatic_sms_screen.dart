import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadsos_mobile/core/theme/app_theme.dart';

// ---------------------------------------------------------------
// Automatic SMS Contact Model
// ---------------------------------------------------------------
class SmsContact {
  String name;
  String phone;

  SmsContact({required this.name, required this.phone});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };

  factory SmsContact.fromJson(Map<String, dynamic> json) {
    return SmsContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }
}

// ---------------------------------------------------------------
// Automatic SMS Screen
// ---------------------------------------------------------------
class AutomaticSmsScreen extends StatefulWidget {
  const AutomaticSmsScreen({super.key});

  @override
  State<AutomaticSmsScreen> createState() => _AutomaticSmsScreenState();
}

class _AutomaticSmsScreenState extends State<AutomaticSmsScreen> {
  static const MethodChannel _channel = MethodChannel('automatic_sms/sms');

  final TextEditingController messageController = TextEditingController();

  List<SmsContact> contacts = [];
  bool isSending = false;
  String statusMessage = 'Ready';
  Map<int, String> contactStatuses = {};

  @override
  void initState() {
    super.initState();
    loadSavedSettings();
  }

  // ------------------------------------------------------------
  // LOAD SAVED SETTINGS
  // ------------------------------------------------------------
  Future<void> loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedContacts = prefs.getString('contacts_json');
    final savedMessage = prefs.getString('sms_message');

    if (!mounted) return;

    setState(() {
      if (savedContacts != null) {
        final List<dynamic> decoded = jsonDecode(savedContacts);
        contacts = decoded
            .map((e) => SmsContact.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      messageController.text = savedMessage ??
          '🚨 EMERGENCY ALERT: I need immediate roadside/emergency assistance! Please check on me immediately.';
    });
  }

  // ------------------------------------------------------------
  // SAVE SETTINGS
  // ------------------------------------------------------------
  Future<void> saveSettings() async {
    if (contacts.isEmpty) {
      showSnackBar('Please add at least one contact.');
      return;
    }

    final message = messageController.text.trim();
    if (message.isEmpty) {
      showSnackBar('Please enter an SMS message.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'contacts_json',
      jsonEncode(contacts.map((c) => c.toJson()).toList()),
    );
    await prefs.setString('sms_message', message);

    if (!mounted) return;

    setState(() {
      statusMessage = 'Settings saved';
    });

    showSnackBar('Settings saved successfully.');
  }

  // ------------------------------------------------------------
  // ADD CONTACT
  // ------------------------------------------------------------
  void addContact() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add SMS Emergency Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryRed),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+919876543210',
                prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.primaryRed),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final phone = phoneCtrl.text.trim();

              if (name.isEmpty || phone.isEmpty) return;

              setState(() {
                contacts.add(SmsContact(name: name, phone: phone));
              });

              saveSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Add Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EDIT CONTACT
  // ------------------------------------------------------------
  void editContact(int index) {
    final nameCtrl = TextEditingController(text: contacts[index].name);
    final phoneCtrl = TextEditingController(text: contacts[index].phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit SMS Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryRed),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+919876543210',
                prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.primaryRed),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final phone = phoneCtrl.text.trim();

              if (name.isEmpty || phone.isEmpty) return;

              setState(() {
                contacts[index] = SmsContact(name: name, phone: phone);
              });

              saveSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // REMOVE CONTACT
  // ------------------------------------------------------------
  void removeContact(int index) {
    final contact = contacts[index];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Remove "${contact.name}" (${contact.phone}) from Automatic SMS dispatch list?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () {
              setState(() {
                contacts.removeAt(index);
                contactStatuses.clear();
              });
              saveSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TRIGGER SOS — send to ALL contacts via Native SMS Channel
  // ------------------------------------------------------------
  Future<void> triggerSOS() async {
    if (contacts.isEmpty) {
      showSnackBar('No contacts configured. Please add contacts first.');
      return;
    }

    final message = messageController.text.trim();
    if (message.isEmpty) {
      showSnackBar('No SMS message configured.');
      return;
    }

    await saveSettings();

    if (!mounted) return;

    setState(() {
      isSending = true;
      statusMessage = 'Sending SMS to ${contacts.length} contact(s)...';
      contactStatuses.clear();
    });

    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < contacts.length; i++) {
      if (!mounted) return;

      setState(() {
        contactStatuses[i] = 'Sending...';
      });

      try {
        final result = await _channel.invokeMethod<String>(
          'sendSms',
          {
            'phoneNumber': contacts[i].phone,
            'message': message,
          },
        );

        if (!mounted) return;

        setState(() {
          contactStatuses[i] = result ?? 'Sent ✓';
        });

        successCount++;
      } on PlatformException catch (e) {
        if (!mounted) return;

        setState(() {
          contactStatuses[i] = e.message ?? 'Failed ✗';
        });

        failCount++;
      } catch (e) {
        if (!mounted) return;

        setState(() {
          contactStatuses[i] = 'Error ✗';
        });

        failCount++;
      }
    }

    if (!mounted) return;

    setState(() {
      isSending = false;
      statusMessage = 'Done — $successCount sent, $failCount failed';
    });

    showSnackBar(
      'SMS sent to $successCount of ${contacts.length} contact(s).',
    );
  }

  // ------------------------------------------------------------
  // CLEAR SETTINGS
  // ------------------------------------------------------------
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('contacts_json');
    await prefs.remove('sms_message');

    if (!mounted) return;

    setState(() {
      contacts.clear();
      contactStatuses.clear();
      messageController.text =
          '🚨 EMERGENCY ALERT: I need immediate roadside/emergency assistance! Please check on me immediately.';
      statusMessage = 'Settings cleared';
    });

    showSnackBar('All SMS settings cleared.');
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.cardDark),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automatic SMS SOS', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryRed, Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRed.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.sms_rounded, size: 54, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Automatic SMS System',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Dispatches direct cellular SMS to multiple emergency contacts without requiring active internet data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contacts Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency Recipients (${contacts.length})',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cardDark,
                      side: const BorderSide(color: AppTheme.primaryRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: isSending ? null : addContact,
                    icon: const Icon(Icons.person_add_rounded, color: AppTheme.primaryRed, size: 16),
                    label: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Empty State
              if (contacts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline_rounded, size: 44, color: AppTheme.textSecondary.withValues(alpha: 0.6)),
                      const SizedBox(height: 10),
                      const Text('No SMS contacts configured yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Tap "+ Add" or "Import" to setup emergency recipients.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                )
              else
                ...contacts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final contact = entry.value;
                  final status = contactStatuses[index];

                  Color statusColor = AppTheme.textSecondary;
                  if (status != null) {
                    if (status.contains('Sent') || status.contains('success')) {
                      statusColor = AppTheme.successGreen;
                    } else if (status.contains('Sending')) {
                      statusColor = AppTheme.accentOrange;
                    } else if (status.contains('Fail') || status.contains('Error') || status.contains('DENIED')) {
                      statusColor = AppTheme.primaryRed;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryRed.withValues(alpha: 0.2),
                        child: Text(
                          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(contact.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(contact.phone, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          if (status != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                status,
                                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSecondary),
                            onPressed: isSending ? null : () => editContact(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.primaryRed),
                            onPressed: isSending ? null : () => removeContact(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),

              // Emergency Message Text Box
              const Text('Emergency SMS Message Template', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Emergency Text Message',
                  hintText: 'Enter emergency SOS message...',
                  prefixIcon: Icon(Icons.message_rounded, color: AppTheme.primaryRed),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // Save Settings Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cardDark,
                  side: const BorderSide(color: AppTheme.accentOrange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isSending ? null : saveSettings,
                icon: const Icon(Icons.save_rounded, color: AppTheme.accentOrange),
                label: const Text('SAVE SMS SETTINGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),

              // Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSending ? Icons.sync_rounded : Icons.info_outline_rounded,
                      color: isSending ? AppTheme.accentOrange : AppTheme.successGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Status: $statusMessage',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // How It Works Explanatory Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text('Automatic Emergency SMS Engine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '• Automatically dispatches SMS when a crash is detected by Ride Mode sensors.\n'
                      '• Includes custom message, accurate offline GPS coordinates, and Google Maps link.\n'
                      '• Operates 100% offline via SIM card without mobile data or Wi-Fi.\n'
                      '• Keep recipients and emergency template configured here.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Clear Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isSending ? null : clearSettings,
                icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.textSecondary),
                label: const Text('Clear All SMS Settings', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

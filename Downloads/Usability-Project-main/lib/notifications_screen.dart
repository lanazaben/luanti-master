import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'side_menu.dart';
import 'app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final double buttonWidth = 110.0;
  final String baseUrl = 'http://localhost:3000'; // Change to your backend URL
  List<Map<String, dynamic>> alerts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/alerts/pending'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          alerts = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load alerts';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error connecting to server: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _makeDecision(int alertId, String decision) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/alerts/$alertId/decision'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'decision': decision}),
      );

      if (response.statusCode == 200) {
        // Refresh alerts after decision
        _fetchAlerts();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Decision "$decision" applied successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to apply decision'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getChildName(int? childId) {
    // In a real app, you'd fetch this from the children API
    // For now, return a default
    return "Your child";
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E2D2),
      drawer: const SideMenu(),
      appBar: const CustomAppBar(title: "Notifications"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchAlerts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : alerts.isEmpty
                  ? const Center(
                      child: Text(
                        'No pending alerts',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchAlerts,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView.builder(
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return _buildNotificationCard(alert);
                          },
                        ),
                      ),
                    ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> alert) {
    final childName = _getChildName(alert['childId']);
    final sender = alert['sender'] ?? 'Unknown';
    final reason = alert['reason'] ?? 'Content flagged';
    final severity = alert['severity'] ?? 'medium';
    final message = alert['message'] ?? '';

    return InkWell(
      onTap: () => _showViewAlert(alert, childName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD6E6D1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getSeverityColor(severity),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Alert from Launti game",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              "Reason: $reason",
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              "From: $sender",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  void _showViewAlert(Map<String, dynamic> alert, String childName) {
    final sender = alert['sender'] ?? 'Unknown';
    final reason = alert['reason'] ?? 'Content flagged';
    final message = alert['message'] ?? '';
    final alertId = alert['id'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            Text(
              sender,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "Alert from Launti Game",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Reason: $reason",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "A message was detected that may pose a risk to your child.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),
            const Text(
              "Choose an action:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDecisionButton(
                  "Block",
                  Colors.red,
                  Colors.white,
                  () {
                    Navigator.pop(context);
                    _makeDecision(alertId, "BLOCK");
                  },
                ),
                const SizedBox(width: 8),
                _buildDecisionButton(
                  "Flag",
                  Colors.orange,
                  Colors.white,
                  () {
                    Navigator.pop(context);
                    _makeDecision(alertId, "FLAG");
                  },
                ),
                const SizedBox(width: 8),
                _buildDecisionButton(
                  "Allow",
                  Colors.green,
                  Colors.white,
                  () {
                    Navigator.pop(context);
                    _makeDecision(alertId, "ALLOW");
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildUnifiedButton(
              "View Message",
              const Color(0xFFF9C846),
              Colors.black,
              () {
                Navigator.pop(context);
                _showDisplayMessage(alert, childName);
              },
            ),
            const SizedBox(height: 10),
            _buildUnifiedButton(
              "Close",
              Colors.grey[400]!,
              Colors.black,
              () {
                Navigator.pop(context);
              },
              width: buttonWidth * 3 + 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showDisplayMessage(Map<String, dynamic> alert, String childName) {
    final message = alert['message'] ?? 'No message content';
    final sender = alert['sender'] ?? 'Unknown';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "The Message",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "From: $sender",
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E6D1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUnifiedButton(
                  "Back",
                  const Color(0xFFF9C846),
                  Colors.black,
                  () {
                    Navigator.pop(context);
                    _showViewAlert(alert, childName);
                  },
                ),
                const SizedBox(width: 10),
                _buildUnifiedButton(
                  "Close",
                  Colors.grey[400]!,
                  Colors.black,
                  () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed, {
    double? width,
  }) {
    return SizedBox(
      width: width ?? buttonWidth,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tik_tok_wikipidiea/screens/profile/book_mark.dart';
import 'package:tik_tok_wikipidiea/services/autoscroll.dart';
import 'package:tik_tok_wikipidiea/services/theme_render.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User data (would typically come from a user service/model)
  String userName = "John Doe";
  String userBio = "Flutter Developer | Tech Enthusiast";
  String avatarUrl = "https://via.placeholder.com/150";

  // Theme toggle
  bool _isDarkMode = false;
  final ThemeService _themeService = ThemeService();

  // Auto scroll settings
  final AutoScrollService _autoScrollService = AutoScrollService();
  bool _autoScrollEnabled = false;
  int _scrollInterval = 5; // seconds
  final List<int> _scrollIntervals = [3, 5, 10, 15, 30];
  Timer? _scrollTimer;
  final ScrollController _scrollController = ScrollController();

  // Avatar customization options
  List<String> avatarOptions = [
    "https://via.placeholder.com/150/FF5722/FFFFFF",
    "https://via.placeholder.com/150/2196F3/FFFFFF",
    "https://via.placeholder.com/150/4CAF50/FFFFFF",
    "https://via.placeholder.com/150/9C27B0/FFFFFF",
    "https://via.placeholder.com/150/FFEB3B/000000",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize from services
    _autoScrollEnabled = _autoScrollService.enabled;
    _scrollInterval = _autoScrollService.intervalSeconds;

    // Ensure we get the current theme status from the service
    _isDarkMode = _themeService.isDarkMode;

    // Listen for theme changes from other parts of the app
    _themeService.addListener(_onThemeChanged);
  }

  // Add this method to update UI when theme changes from elsewhere
  void _onThemeChanged(ThemeMode mode) {
    if (mounted) {
      setState(() {
        _isDarkMode = mode == ThemeMode.dark;
      });
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _toggleTheme() {
    // Update theme service (which persists the setting)
    _themeService.toggleTheme().then((_) {
      // Update local state
      setState(() {
        _isDarkMode = _themeService.isDarkMode;
      });
    });
  }

  void _toggleAutoScroll(bool value) {
    setState(() {
      _autoScrollEnabled = value;
    });

    // Update service and notify listeners
    _autoScrollService.updateSettings(enabled: value);

    if (_autoScrollEnabled) {
      _startAutoScroll();
    } else {
      _scrollTimer?.cancel();
    }
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(Duration(seconds: _scrollInterval), (_) {
      if (_scrollController.hasClients) {
        final currentPosition = _scrollController.offset;
        final maxPosition = _scrollController.position.maxScrollExtent;

        if (currentPosition < maxPosition) {
          _scrollController.animateTo(
            currentPosition + 100,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _changeScrollInterval(int? interval) {
    if (interval != null) {
      setState(() {
        _scrollInterval = interval;
      });

      // Update service and notify listeners
      _autoScrollService.updateSettings(intervalSeconds: interval);

      if (_autoScrollEnabled) {
        _startAutoScroll(); // Restart with new interval
      }
    }
  }

  void _openAvatarCustomizationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Customize Avatar'),
            content: Container(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: avatarOptions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        avatarUrl = avatarOptions[index];
                      });
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(avatarOptions[index]),
                      radius: 30,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Add haptic feedback
              HapticFeedback.mediumImpact();

              // Define the red theme colors
              final Color redPrimary = Color(0xFFE53935);
              final Color redDark = Color(0xFFC62828);
              final Color redLight = Color(0xFFEF5350);

              // Show enhanced confirmation dialog with animation
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'Dismiss',
                barrierColor: Colors.black87.withOpacity(0.6),
                transitionDuration: Duration(milliseconds: 250),
                pageBuilder: (context, animation1, animation2) => Container(),
                transitionBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: animation,
                      child: Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 12,
                        shadowColor: redDark.withOpacity(0.3),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).cardColor,
                                Theme.of(context).brightness == Brightness.dark
                                    ? Color(0xFF2A1A1A) // Dark mode red tint
                                    : Color(0xFFFFF5F5), // Light mode red tint
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated icon with shield and power symbol
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(milliseconds: 600),
                                curve: Curves.elasticOut,
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Outer glow
                                        Container(
                                          width: 80 * value,
                                          height: 80 * value,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: redPrimary.withOpacity(
                                                  0.15,
                                                ),
                                                blurRadius: 20 * value,
                                                spreadRadius: 5 * value,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Inner circle
                                        Container(
                                          padding: EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: redPrimary.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: redPrimary.withOpacity(
                                                0.5,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.power_settings_new_rounded,
                                            color: redPrimary,
                                            size: 36,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 28),

                              // Title with warning icon
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: redPrimary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback:
                                        (bounds) => LinearGradient(
                                          colors: [redPrimary, redDark],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                    child: Text(
                                      'Logout Account',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),

                              // Divider with gradient
                              Container(
                                width: 50,
                                height: 3,
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      redLight.withOpacity(0.7),
                                      redDark,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),

                              // Personalized message with username and current date
                              Column(
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(height: 1.5),
                                      children: [
                                        TextSpan(
                                          text:
                                              'Are you sure you want to log out from ',
                                        ),
                                        TextSpan(
                                          text: '@ashirwad5555',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: redPrimary,
                                          ),
                                        ),
                                        TextSpan(text: '?'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    '2025-03-22 17:26:32 UTC',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 32),

                              // Buttons with enhanced styling
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.of(context).pop();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: theme.dividerColor,
                                        ),
                                        foregroundColor:
                                            theme.textTheme.bodyLarge?.color,
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();

                                        // Show loading indicator
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(redPrimary),
                                              ),
                                            );
                                          },
                                        );

                                        // Simulate logout process
                                        Future.delayed(
                                          Duration(milliseconds: 800),
                                          () {
                                            Navigator.of(
                                              context,
                                            ).pop(); // Close loading dialog
                                            Navigator.of(
                                              context,
                                            ).pop(); // Close logout dialog

                                            // Show success snackbar
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Successfully logged out',
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: redPrimary,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );

                                            // Navigate to login screen
                                            // Navigator.of(context).pushReplacementNamed('/login');
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        backgroundColor: redPrimary,
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        shadowColor: redPrimary.withOpacity(
                                          0.4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        children: [
          // Profile Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: _openAvatarCustomizationDialog,
                          tooltip: 'Customize avatar',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    userName,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userBio,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Edit Profile'),
                    onPressed: () {
                      // Navigate to edit profile page
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Settings Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Auto Scroll Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Auto Scroll', style: theme.textTheme.bodyMedium),
                      Switch(
                        value: _autoScrollEnabled,
                        onChanged: _toggleAutoScroll,
                        activeColor: theme.primaryColor,
                      ),
                    ],
                  ),

                  // Auto Scroll Interval Dropdown (visible only when auto scroll is enabled)
                  if (_autoScrollEnabled) ...[
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scroll Interval',
                          style: theme.textTheme.bodyMedium,
                        ),
                        DropdownButton<int>(
                          value: _scrollInterval,
                          items:
                              _scrollIntervals.map((int interval) {
                                return DropdownMenuItem<int>(
                                  value: interval,
                                  child: Text('$interval seconds'),
                                );
                              }).toList(),
                          onChanged: _changeScrollInterval,
                          dropdownColor: theme.cardColor,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],

                  Divider(height: 32),

                  // Theme Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dark Mode', style: theme.textTheme.bodyMedium),
                      Switch(
                        value: _isDarkMode,
                        onChanged: (value) => _toggleTheme(),
                        activeColor: theme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Stats Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Stats',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Articles Read - regular stat
                  _buildStatRow('Articles Read', '42', theme),
                  SizedBox(height: 12),

                  // Bookmarks - clickable stat that navigates to bookmarks page
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookmarksPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Bookmarks',
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: theme.iconTheme.color,
                              ),
                            ],
                          ),
                          Text(
                            '15', // This would normally come from a real count
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Comments - regular stat
                  _buildStatRow('Comments', '7', theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String result = 'none';
  String imageResult = 'none';
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> predictGender(String name) async {
    if (name.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      var url = Uri.parse('https://api.genderize.io/?name=$name');
      var response = await http.get(url);
      var body = json.decode(response.body);

      setState(() {
        result = body['gender'] != null
            ? 'Gender: ${body['gender']}'
            : 'Gender could not be predicted';
        imageResult = body['gender'] ?? 'both';
        isLoading = false;
        _controller.forward(from: 0);
      });
    } catch (e) {
      setState(() {
        result = 'Error: Failed to fetch data';
        isLoading = false;
      });
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (themeNotifier.isDarkMode) {
      return Colors.grey.shade900;
    } else if (imageResult == 'male') {
      return Colors.blue.shade100;
    } else if (imageResult == 'female') {
      return Colors.pink.shade100;
    }
    return Colors.teal.shade50;
  }

  LinearGradient _getAppBarGradient(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (themeNotifier.isDarkMode) {
      return LinearGradient(
        colors: [Colors.grey.shade800, Colors.black87],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (imageResult == 'male') {
      return LinearGradient(
        colors: [Colors.blue.shade400, Colors.blue.shade700],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (imageResult == 'female') {
      return LinearGradient(
        colors: [Colors.pink.shade300, Colors.pink.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [Colors.teal.shade400, Colors.teal.shade700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Gender Genie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: _getAppBarGradient(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Enter a Name to Predict Gender',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInputField(isDarkMode),
              const SizedBox(height: 20),
              _buildPredictButton(),
              const SizedBox(height: 30),
              if (isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                )
              else if (_nameController.text.isEmpty)
                Text(
                  'Please enter a name.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade400,
                  ),
                )
              else
                _buildResultSection(isDarkMode),
              const SizedBox(height: 20),
              // Text(
              //   'Created by Rensith Udara ❤️',
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter a name',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: isDarkMode ? Colors.teal.shade200 : Colors.teal.shade700,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.clear,
              color: isDarkMode ? Colors.teal.shade200 : Colors.teal.shade700,
            ),
            onPressed: () {
              _nameController.clear();
              setState(() {
                result = 'none';
                imageResult = 'none';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPredictButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => predictGender(_nameController.text),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Predict',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _curvedAnimation.value,
          child: Transform.scale(
            scale: _curvedAnimation.value,
            child: Column(
              children: [
                Text(
                  result,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                if (imageResult == 'both')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGenderImage('male', isDarkMode),
                      const SizedBox(width: 20),
                      _buildGenderImage('female', isDarkMode),
                    ],
                  )
                else
                  _buildGenderImage(imageResult, isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderImage(String gender, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: gender == 'male'
              ? Colors.blueAccent.shade200
              : Colors.pinkAccent.shade200,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/$gender.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
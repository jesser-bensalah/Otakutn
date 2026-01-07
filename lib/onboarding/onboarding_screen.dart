import 'package:flutter/material.dart';
import 'package:otakutn/pages/login_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart' as smooth_indicator;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'title': 'Welcome to OtakuTN',
      'description': 'Discover the best of Japanese animation in an immersive experience',
      'image': 'assets/onboarding1.png',
      'color': Colors.deepPurple,
      'icon': Icons.play_circle_filled_rounded,
    },
    {
      'title': 'Explore Animes',
      'description': 'Browse a vast collection of popular animes and discover hidden gems',
      'image': 'assets/onboarding2.png',
      'color': Colors.blue,
      'icon': Icons.explore_rounded,
    },
    {
      'title': 'Start Your Adventure',
      'description': 'Join our passionate community and dive into the world of anime',
      'image': 'assets/onboarding3.png',
      'color': Colors.pink,
      'icon': Icons.rocket_launch_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            onboardingData[_currentPage]['color'].withOpacity(0.3),
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxImage(int index) {
    double parallaxOffset = (index - _pageOffset) * 100;
    final screenSize = MediaQuery.of(context).size;
    final padding = 20.0; 
    
    
    if ((_pageOffset - index).abs() >= 1.0) {
      return const SizedBox.shrink();
    }

    return Transform.translate(
      offset: Offset(parallaxOffset, 0),
      child: Opacity(
        opacity: (1 - (_pageOffset - index).abs()).clamp(0.0, 1.0),
        child: Center(
          child: Container(
            height: screenSize.height * 0.8, 
            width: screenSize.width - (padding * 2), 
            margin: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                onboardingData[index]['image'],
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: onboardingData[index]['color'].withOpacity(0.2),
                    child: Center(
                      child: Icon(
                        onboardingData[index]['icon'],
                        size: 60,
                        color: onboardingData[index]['color'],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    double scale = 1 - (_pageOffset - index).abs() * 0.3;
    double opacity = (1 - (_pageOffset - index).abs()).clamp(0.0, 1.0);
    
    return Transform.scale(
      scale: scale.clamp(0.8, 1.0),
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 120.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon animé
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: onboardingData[index]['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  onboardingData[index]['icon'],
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              
              // Title with animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  onboardingData[index]['title'],
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Delayed description animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 700),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  onboardingData[index]['description'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         
          _buildAnimatedBackground(),
          
          // Images en parallaxe
          ...List.generate(onboardingData.length, (index) {
            return _buildParallaxImage(index);
          }),
          
          // Overlay de dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.95),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          
      
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPageContent(index);
            },
          ),
          
          // Bottom controls
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  // Custom page indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous button (visible except on the first page)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _currentPage > 0 ? 1.0 : 0.0,
                          child: IconButton(
                            onPressed: _currentPage > 0 
                                ? () => _pageController.previousPage(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOutCubic,
                                    )
                                : null,
                            icon: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        
                        // Progress indicator
                        smooth_indicator.SmoothPageIndicator(
                          controller: _pageController,
                          count: onboardingData.length,
                          effect: smooth_indicator.ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: onboardingData[_currentPage]['color'],
                            dotColor: Colors.white.withOpacity(0.3),
                            expansionFactor: 3,
                            spacing: 6,
                          ),
                        ),
                        
                        // Next/Start button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _currentPage == onboardingData.length - 1
                              ? _buildGetStartedButton()
                              : _buildNextButton(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10), 
                  
                 
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage < onboardingData.length - 1 ? 1.0 : 0.0,
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return FloatingActionButton(
      onPressed: _onNext,
      backgroundColor: onboardingData[_currentPage]['color'],
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return ElevatedButton.icon(
      onPressed: _navigateToLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: onboardingData[_currentPage]['color'],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
        shadowColor: onboardingData[_currentPage]['color'].withOpacity(0.5),
      ),
      icon: const Icon(Icons.rocket_launch_rounded, size: 20),
      label: const Text(
        'Commencer',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
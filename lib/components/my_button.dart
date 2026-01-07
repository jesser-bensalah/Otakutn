import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String value;
  final bool isPrimary;

  const MyButton({
    super.key, 
    required this.onTap, 
    required this.value,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          gradient: isPrimary 
              ? LinearGradient(
                  colors: [
                    Colors.deepPurple,
                    Colors.pink,
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.deepPurple, width: 2),
          boxShadow: isPrimary 
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: isPrimary ? Colors.white : Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
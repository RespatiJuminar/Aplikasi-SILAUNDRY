import 'package:flutter/material.dart';
import '../widgets/shell.dart';
import 'dashboard_page.dart';

const _monoStyle = TextStyle(
  fontFamily: 'Consolas',
  fontFamilyFallback: ['Courier New', 'monospace'],
  fontWeight: FontWeight.bold,
  color: Colors.white,
  shadows: [Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3))],
);

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/landing_bg.jpg', fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.fromLTRB(78, 70, 40, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome To Our\nApplication',
                        style: TextStyle(
                          fontFamily: 'Consolas',
                          fontFamilyFallback: ['Courier New', 'monospace'],
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 54,
                          height: 1.3,
                          shadows: [
                            Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Click Button Below to Start the Program',
                        style: _monoStyle.copyWith(fontSize: 24),
                      ),
                      const Spacer(),
                      _StartButton(
                        onTap: () => replacePage(context, const DashboardPage()),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 224,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF6C7BFF), Color(0xFFDA82F7)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text("Get's Started", style: _monoStyle.copyWith(fontSize: 22, shadows: [])),
        ),
      ),
    );
  }
}

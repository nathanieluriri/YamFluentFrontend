import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBottomNavBar extends StatefulWidget {
  final int activeIndex;
  final Future<void> Function(int)? onTap;

  const AppBottomNavBar({super.key, this.activeIndex = 0, this.onTap});

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  int? _overrideIndex;

  Future<void> _handleTap(int index) async {
    final handler = widget.onTap;
    if (handler == null) return;
    if (index == 1) {
      setState(() => _overrideIndex = 1);
      await handler(index);
      if (!mounted) return;
      setState(() => _overrideIndex = null);
      return;
    }
    await handler(index);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIndex = _overrideIndex ?? widget.activeIndex;
    final width = math.min(MediaQuery.of(context).size.width - 48, 300.0);
    const activeBgColor = Color(0xFF2EA9DE);

    final items = [
      _NavItemData(
        activeAsset: 'assets/icons/active_home_bottom_Nav_icon.svg',
        inactiveAsset: 'assets/icons/inactive_home_bottom_Nav_icon.svg',
        isActive: effectiveIndex == 0,
        onTap: widget.onTap == null ? null : () => _handleTap(0),
      ),
      _NavItemData(
        activeAsset: 'assets/icons/active_start_speaking_bottom_Nav_icon.svg',
        inactiveAsset:
            'assets/icons/inactive_start_speaking_bottom_Nav_icon.svg',
        isActive: effectiveIndex == 1,
        onTap: widget.onTap == null ? null : () => _handleTap(1),
      ),
      _NavItemData(
        activeAsset: 'assets/icons/active_feedback_bottom_Nav_icon.svg',
        inactiveAsset: 'assets/icons/inactive_feedback_bottom_Nav_icon.svg',
        isActive: effectiveIndex == 2,
        onTap: widget.onTap == null ? null : () => _handleTap(2),
      ),
      _NavItemData(
        activeAsset: 'assets/icons/active_settings_bottom_Nav_icon.svg',
        inactiveAsset: 'assets/icons/inactive_settings_bottom_Nav_icon.svg',
        isActive: effectiveIndex == 3,
        onTap: widget.onTap == null ? null : () => _handleTap(3),
      ),
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 24),
        child: Container(
          width: width,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(500),
            // border: Border.all(color: const Color(0xFFEBEBEB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.008),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items
                .map(
                  (item) => _NavItem(data: item, activeBgColor: activeBgColor),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final Color activeBgColor;

  const _NavItem({required this.data, required this.activeBgColor});

  @override
  Widget build(BuildContext context) {
    // If active, show bigger circle with color.
    // If inactive, show just icon.
    return Expanded(
      child: GestureDetector(
        onTap: data.onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48,
            width: data.isActive ? 80 : 48,
            decoration: BoxDecoration(
              color: data.isActive ? activeBgColor : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(data.isActive ? 30 : 999),
            ),
            child: Center(
              child: SvgPicture.asset(
                data.isActive ? data.activeAsset : data.inactiveAsset,
                height: 24,
                width: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String activeAsset;
  final String inactiveAsset;
  final bool isActive;
  final VoidCallback? onTap;

  _NavItemData({
    required this.activeAsset,
    required this.inactiveAsset,
    required this.isActive,
    this.onTap,
  });
}

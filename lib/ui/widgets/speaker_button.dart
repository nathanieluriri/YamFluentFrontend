import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpeakerButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const SpeakerButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPlaying ? const Color(0xFF2EA9DE) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: SvgPicture.asset(
          'assets/icons/speaker_in_conversation.svg',
          colorFilter: ColorFilter.mode(
            isPlaying ? Colors.white : Colors.black87,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

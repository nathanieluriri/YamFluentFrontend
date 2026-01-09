import 'package:flutter/material.dart';

import 'waveform_bars.dart';

class RecorderMicButton extends StatelessWidget {
  final bool isRecording;
  final bool isUploading;
  final double amplitude;
  final VoidCallback onTap;

  const RecorderMicButton({
    super.key,
    required this.isRecording,
    required this.isUploading,
    required this.amplitude,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pulseScale = isRecording ? 1.0 + (amplitude * 0.25) : 1.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRecording) ...[
          WaveformBars(amplitude: amplitude),
          const SizedBox(height: 8),
          Text(
            'You are doing great!',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
        ],
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: pulseScale,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2EA9DE).withOpacity(0.12),
                ),
              ),
            ),
            GestureDetector(
              onTap: isUploading ? null : onTap,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2EA9DE),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: isUploading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          isRecording ? 'Listening.. Tap to stop' : 'Tap to record your answer',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

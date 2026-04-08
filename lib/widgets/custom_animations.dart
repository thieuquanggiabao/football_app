import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Shake Animation Widget - Rung khi có lỗi
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double distance;
  final VoidCallback? onComplete;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.distance = 10.0,
    this.onComplete,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller.forward(from: 0.0).then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double value = _controller.value;
        // Tạo sin wave để rung qua lại
        final double offset = math.sin(value * math.pi * 4) * widget.distance;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Glowing Effect Widget - Viền sáng khi được focus
class GlowingInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final Color glowColor;
  final Duration glowDuration;

  const GlowingInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.glowColor = Colors.greenAccent,
    this.glowDuration = const Duration(milliseconds: 300),
  });

  @override
  State<GlowingInputField> createState() => _GlowingInputFieldState();
}

class _GlowingInputFieldState extends State<GlowingInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: widget.glowDuration,
      vsync: this,
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _glowController.forward();
    } else {
      _glowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_glowController.value * 0.6),
                blurRadius: 20 * _glowController.value,
                spreadRadius: 5 * _glowController.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: widget.isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: Colors.white54)
              : null,
          filled: true,
          fillColor: Colors.grey[900],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.greenAccent,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}

/// Parallax Background Widget - Hiệu ứng nền parallax
class ParallaxBackground extends StatefulWidget {
  final String imageUrl;
  final ScrollController scrollController;
  final double height;

  const ParallaxBackground({
    super.key,
    required this.imageUrl,
    required this.scrollController,
    this.height = 250.0,
  });

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  late double _offset;

  @override
  void initState() {
    super.initState();
    _offset = 0;
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _offset = widget.scrollController.offset * 0.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, _offset),
          child: Image.network(
            widget.imageUrl,
            height: widget.height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: widget.height,
                color: Colors.grey[800],
              );
            },
          ),
        ),
        // Blur/Fade effect
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular Reveal Animation - Hiệu ứng mở rộng vòng tròn
class CircularReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Alignment alignment;
  final bool startAnimation;

  const CircularReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.alignment = Alignment.center,
    this.startAnimation = true,
  });

  @override
  State<CircularReveal> createState() => _CircularRevealState();
}

class _CircularRevealState extends State<CircularReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    if (widget.startAnimation) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void reveal() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipPath(
          clipper: CircleRevealClipper(
            progress: _controller.value,
            alignment: widget.alignment,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Custom Clipper cho Circular Reveal
class CircleRevealClipper extends CustomClipper<Path> {
  final double progress;
  final Alignment alignment;

  CircleRevealClipper({
    required this.progress,
    this.alignment = Alignment.center,
  });

  @override
  Path getClip(Size size) {
    final centerX = alignment.x * size.width / 2 + size.width / 2;
    final centerY = alignment.y * size.height / 2 + size.height / 2;
    final maxDistance = math.sqrt(size.width * size.width + size.height * size.height) / 2;

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: maxDistance * progress,
        ),
      );
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.alignment != alignment;
  }
}

/// Blurred Background Widget - Nền mờ
class BlurredBackground extends StatelessWidget {
  final String imageUrl;
  final Widget child;
  final double opacity;

  const BlurredBackground({
    super.key,
    required this.imageUrl,
    required this.child,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black);
            },
          ),
        ),
        Container(
          color: Colors.black.withOpacity(opacity),
        ),
        child,
      ],
    );
  }
}

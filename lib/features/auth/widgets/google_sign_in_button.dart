// ============================================================
// google_sign_in_button.dart — "Continue with Google" button
// ============================================================
// A reusable button that looks like a standard Google sign-in button.
// Used on both the Login and Register screens.
// ============================================================

import 'package:flutter/material.dart';

/// A styled button for Google sign-in.
///
/// [onPressed] — the function to call when the button is tapped.
/// [isLoading] — shows a spinner when true (prevents double-taps).
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      // Disable the button while loading
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show spinner or Google "G" icon
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            // Google "G" logo — we use a simple text representation
            // In a real app, you'd use an SVG or image asset
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4285F4), // Google Blue
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          const Text('Continue with Google'),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Map a backend exception to a plain-English, user-facing sentence with a next
/// action (CLAUDE.md §6). Never surfaces a raw exception or stack trace.
String mapError(Object error) {
  if (error is AuthException) {
    final m = error.message.toLowerCase();
    if (m.contains('rate') || m.contains('too many') || m.contains('limit')) {
      return 'Too many attempts. Wait a minute, then try again.';
    }
    if (m.contains('expired')) {
      return 'That code has expired. Request a new one.';
    }
    if (m.contains('invalid') || m.contains('token') || m.contains('otp')) {
      return "That code isn't right. Check it and try again.";
    }
    return 'Sign-in failed. Please try again.';
  }
  if (error is PostgrestException) {
    return 'Something went wrong saving that. Please try again.';
  }
  if (error is StorageException) {
    return 'A photo failed to upload. Check your connection and retry.';
  }
  if (error is SocketException || error is TimeoutException) {
    return 'No internet connection. Check your network and try again.';
  }
  return 'Something went wrong. Please try again.';
}

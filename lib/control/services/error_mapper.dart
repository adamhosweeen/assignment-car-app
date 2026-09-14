import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

String mapError(Object error) {
  if (error is AuthException) {
    final m = error.message.toLowerCase();
    if (m.contains('banned')) {
      return 'This account has been banned.';
    }
    if (m.contains('rate') || m.contains('too many') || m.contains('limit')) {
      return 'Too many attempts. Wait a minute, then try again.';
    }
    if (m.contains('invalid login credentials') ||
        m.contains('invalid_credentials')) {
      return 'Email or password is incorrect. Check them and try again.';
    }
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'An account with this email already exists. Log in instead.';
    }
    if (m.contains('email not confirmed')) {
      return 'Confirm your email first — check your inbox.';
    }
    if (m.contains('password')) {
      return 'That password is too weak. Use at least 8 characters with '
          'letters and numbers.';
    }
    if (m.contains('email')) {
      return "That email address doesn't look right. Check it and try again.";
    }
    return 'Sign-in failed. Please try again.';
  }
  if (error is PostgrestException) {
    if (error.code == 'PGRST202') {
      return 'This feature is not available on the server yet. The database '
          'is missing an update.';
    }
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

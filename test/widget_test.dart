// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list_app/services/auth_service.dart';

void main() {
  group('username validation', () {
    test('accepts usernames case-insensitively after trimming', () {
      expect(AuthService.isValidUsername('  Maya_Lin  '), isTrue);
    });

    test('rejects usernames outside the allowed format', () {
      expect(AuthService.isValidUsername('ab'), isFalse);
      expect(AuthService.isValidUsername('maya lin'), isFalse);
      expect(AuthService.isValidUsername('maya.lin'), isFalse);
      expect(AuthService.isValidUsername('this_username_is_too_long'), isFalse);
    });
  });
}

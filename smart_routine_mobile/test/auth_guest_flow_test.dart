import 'package:flutter_test/flutter_test.dart';
import 'package:smart_routine_mobile/features/auth/models/user_model.dart';

void main() {
  group('UserModel & Guest Mode Verification', () {
    test('Correctly identifies registered student from API JSON', () {
      final json = {
        'id': '6ae02f175fc82a820ebede8b',
        'name': 'Jane Student',
        'email': 'jane.student@cse.edu',
        'studentId': 'CSE-2026-001',
        'department': 'Computer Science',
        'institution': 'University of Engineering',
        'isGuest': false,
      };

      final user = UserModel.fromJson(json);

      expect(user.isGuest, isFalse);
      expect(user.id, equals('6ae02f175fc82a820ebede8b'));
      expect(user.email, equals('jane.student@cse.edu'));
      expect(user.name, equals('Jane Student'));
    });

    test('Correctly identifies guest user from isGuest flag', () {
      final json = {
        'id': 'guest_session_123',
        'name': 'Guest Student',
        'email': 'temp_guest@cse.edu',
        'isGuest': true,
      };

      final user = UserModel.fromJson(json);

      expect(user.isGuest, isTrue);
    });

    test('Correctly identifies guest user from guest email fallback', () {
      final json = {
        'id': 'some_id_999',
        'name': 'Guest Student',
        'email': 'guest@cse.edu',
      };

      final user = UserModel.fromJson(json);

      expect(user.isGuest, isTrue);
    });

    test('Correctly identifies guest user from offline fallback ID', () {
      final json = {
        'id': 'guest_user_offline_id',
        'name': 'Guest Student',
        'email': 'random@something.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.isGuest, isTrue);
    });

    test('toJson and copyWith preserves isGuest status', () {
      final guest = UserModel(
        id: 'guest_1',
        name: 'Guest Tester',
        email: 'guest@cse.edu',
        isGuest: true,
      );

      final copy = guest.copyWith(name: 'Updated Guest');
      expect(copy.isGuest, isTrue);

      final map = guest.toJson();
      expect(map['isGuest'], isTrue);
    });
  });
}

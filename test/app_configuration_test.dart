import 'package:clinical_companion/core/config/app_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an unconfigured build remains local-first', () {
    const configuration = AppConfiguration(
      supabaseUrl: '',
      supabaseAnonKey: '',
      ownerId: 'local-practitioner',
    );

    expect(configuration.hasSupabase, isFalse);
    expect(configuration.ownerId, isNotEmpty);
  });
}

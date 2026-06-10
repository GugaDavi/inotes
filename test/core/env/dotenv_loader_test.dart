import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inotes/core/env/dotenv_loader.dart';

class MockDotEnv extends Mock implements DotEnv {}

void main() {
  late MockDotEnv mockDotEnv;
  late DotenvLoader loader;

  setUp(() {
    mockDotEnv = MockDotEnv();
    loader = DotenvLoader(mockDotEnv);
  });

  group('DotenvLoader', () {
    test('get() returns value when key exists', () {
      when(() => mockDotEnv.maybeGet('API_KEY', fallback: any(named: 'fallback'))).thenReturn('my_value');

      expect(loader.get('API_KEY'), 'my_value');
    });

    test('get() throws ArgumentError when key is not found', () {
      when(() => mockDotEnv.maybeGet('MISSING', fallback: any(named: 'fallback'))).thenReturn(null);

      expect(() => loader.get('MISSING'), throwsA(isA<ArgumentError>()));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/network/secure_storage_service.dart';
import 'package:felo_na/core/errors/exceptions.dart';

// Generate mocks
@GenerateMocks([FlutterSecureStorage])
import 'secure_storage_service_test.mocks.dart';

void main() {
  late SecureStorageServiceImpl secureStorageService;
  late MockFlutterSecureStorage mockFlutterSecureStorage;

  setUp(() {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    secureStorageService = SecureStorageServiceImpl(
      storage: mockFlutterSecureStorage,
    );
  });

  group('SecureStorageServiceImpl', () {
    const testKey = 'test_key';
    const testValue = 'test_value';

    group('write', () {
      test('should successfully write key-value pair to secure storage',
          () async {
        // Arrange
        when(mockFlutterSecureStorage.write(key: testKey, value: testValue))
            .thenAnswer((_) async => Future.value());

        // Act
        await secureStorageService.write(testKey, testValue);

        // Assert
        verify(mockFlutterSecureStorage.write(key: testKey, value: testValue))
            .called(1);
      });

      test('should throw StorageException when write operation fails',
          () async {
        // Arrange
        when(mockFlutterSecureStorage.write(key: testKey, value: testValue))
            .thenThrow(Exception('Write failed'));

        // Act & Assert
        expect(
          () => secureStorageService.write(testKey, testValue),
          throwsA(isA<StorageException>()),
        );
      });

      test('should include error details in StorageException message',
          () async {
        // Arrange
        const errorMessage = 'Platform error occurred';
        when(mockFlutterSecureStorage.write(key: testKey, value: testValue))
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        try {
          await secureStorageService.write(testKey, testValue);
          fail('Should have thrown StorageException');
        } catch (e) {
          expect(e, isA<StorageException>());
          expect((e as StorageException).message, contains(errorMessage));
          expect(e.code, equals('WRITE_ERROR'));
        }
      });
    });

    group('read', () {
      test('should successfully read value from secure storage', () async {
        // Arrange
        when(mockFlutterSecureStorage.read(key: testKey))
            .thenAnswer((_) async => testValue);

        // Act
        final result = await secureStorageService.read(testKey);

        // Assert
        expect(result, equals(testValue));
        verify(mockFlutterSecureStorage.read(key: testKey)).called(1);
      });

      test('should return null when key does not exist', () async {
        // Arrange
        when(mockFlutterSecureStorage.read(key: testKey))
            .thenAnswer((_) async => null);

        // Act
        final result = await secureStorageService.read(testKey);

        // Assert
        expect(result, isNull);
        verify(mockFlutterSecureStorage.read(key: testKey)).called(1);
      });

      test('should throw StorageException when read operation fails', () async {
        // Arrange
        when(mockFlutterSecureStorage.read(key: testKey))
            .thenThrow(Exception('Read failed'));

        // Act & Assert
        expect(
          () => secureStorageService.read(testKey),
          throwsA(isA<StorageException>()),
        );
      });

      test('should include error details in StorageException message',
          () async {
        // Arrange
        const errorMessage = 'Permission denied';
        when(mockFlutterSecureStorage.read(key: testKey))
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        try {
          await secureStorageService.read(testKey);
          fail('Should have thrown StorageException');
        } catch (e) {
          expect(e, isA<StorageException>());
          expect((e as StorageException).message, contains(errorMessage));
          expect(e.code, equals('READ_ERROR'));
        }
      });
    });

    group('delete', () {
      test('should successfully delete key from secure storage', () async {
        // Arrange
        when(mockFlutterSecureStorage.delete(key: testKey))
            .thenAnswer((_) async => Future.value());

        // Act
        await secureStorageService.delete(testKey);

        // Assert
        verify(mockFlutterSecureStorage.delete(key: testKey)).called(1);
      });

      test('should throw StorageException when delete operation fails',
          () async {
        // Arrange
        when(mockFlutterSecureStorage.delete(key: testKey))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => secureStorageService.delete(testKey),
          throwsA(isA<StorageException>()),
        );
      });

      test('should include error details in StorageException message',
          () async {
        // Arrange
        const errorMessage = 'Key not found';
        when(mockFlutterSecureStorage.delete(key: testKey))
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        try {
          await secureStorageService.delete(testKey);
          fail('Should have thrown StorageException');
        } catch (e) {
          expect(e, isA<StorageException>());
          expect((e as StorageException).message, contains(errorMessage));
          expect(e.code, equals('DELETE_ERROR'));
        }
      });
    });

    group('deleteAll', () {
      test('should successfully delete all keys from secure storage',
          () async {
        // Arrange
        when(mockFlutterSecureStorage.deleteAll())
            .thenAnswer((_) async => Future.value());

        // Act
        await secureStorageService.deleteAll();

        // Assert
        verify(mockFlutterSecureStorage.deleteAll()).called(1);
      });

      test('should throw StorageException when deleteAll operation fails',
          () async {
        // Arrange
        when(mockFlutterSecureStorage.deleteAll())
            .thenThrow(Exception('DeleteAll failed'));

        // Act & Assert
        expect(
          () => secureStorageService.deleteAll(),
          throwsA(isA<StorageException>()),
        );
      });

      test('should include error details in StorageException message',
          () async {
        // Arrange
        const errorMessage = 'Storage access denied';
        when(mockFlutterSecureStorage.deleteAll())
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        try {
          await secureStorageService.deleteAll();
          fail('Should have thrown StorageException');
        } catch (e) {
          expect(e, isA<StorageException>());
          expect((e as StorageException).message, contains(errorMessage));
          expect(e.code, equals('DELETE_ALL_ERROR'));
        }
      });
    });

    group('edge cases', () {
      test('should handle empty string values', () async {
        // Arrange
        const emptyValue = '';
        when(mockFlutterSecureStorage.write(key: testKey, value: emptyValue))
            .thenAnswer((_) async => Future.value());
        when(mockFlutterSecureStorage.read(key: testKey))
            .thenAnswer((_) async => emptyValue);

        // Act
        await secureStorageService.write(testKey, emptyValue);
        final result = await secureStorageService.read(testKey);

        // Assert
        expect(result, equals(emptyValue));
      });

      test('should handle special characters in keys', () async {
        // Arrange
        const specialKey = 'key_with-special.chars@123';
        when(mockFlutterSecureStorage.write(
                key: specialKey, value: testValue))
            .thenAnswer((_) async => Future.value());

        // Act
        await secureStorageService.write(specialKey, testValue);

        // Assert
        verify(mockFlutterSecureStorage.write(
                key: specialKey, value: testValue))
            .called(1);
      });

      test('should handle special characters in values', () async {
        // Arrange
        const specialValue = 'value with spaces, symbols: !@#\$%^&*()';
        when(mockFlutterSecureStorage.write(
                key: testKey, value: specialValue))
            .thenAnswer((_) async => Future.value());
        when(mockFlutterSecureStorage.read(key: testKey))
            .thenAnswer((_) async => specialValue);

        // Act
        await secureStorageService.write(testKey, specialValue);
        final result = await secureStorageService.read(testKey);

        // Assert
        expect(result, equals(specialValue));
      });

      test('should handle long string values (JWT tokens)', () async {
        // Arrange
        const longValue =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
        when(mockFlutterSecureStorage.write(key: testKey, value: longValue))
            .thenAnswer((_) async => Future.value());
        when(mockFlutterSecureStorage.read(key: testKey))
            .thenAnswer((_) async => longValue);

        // Act
        await secureStorageService.write(testKey, longValue);
        final result = await secureStorageService.read(testKey);

        // Assert
        expect(result, equals(longValue));
      });
    });
  });
}

// Mocks generated manually for secure_storage_service_test.dart

import 'package:mockito/mockito.dart' as _i1;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [FlutterSecureStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockFlutterSecureStorage extends _i1.Mock
    implements _i2.FlutterSecureStorage {
  MockFlutterSecureStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Future<void> write({
    required String? key,
    required String? value,
    _i2.IOSOptions? iOptions,
    _i2.AndroidOptions? aOptions,
    _i2.LinuxOptions? lOptions,
    _i2.WindowsOptions? wOptions,
    _i2.WebOptions? webOptions,
    _i2.MacOsOptions? mOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #write,
          [],
          {
            #key: key,
            #value: value,
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #wOptions: wOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
          },
        ),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>);

  @override
  Future<String?> read({
    required String? key,
    _i2.IOSOptions? iOptions,
    _i2.AndroidOptions? aOptions,
    _i2.LinuxOptions? lOptions,
    _i2.WindowsOptions? wOptions,
    _i2.WebOptions? webOptions,
    _i2.MacOsOptions? mOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #read,
          [],
          {
            #key: key,
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #wOptions: wOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
          },
        ),
        returnValue: Future<String?>.value(),
      ) as Future<String?>);

  @override
  Future<void> delete({
    required String? key,
    _i2.IOSOptions? iOptions,
    _i2.AndroidOptions? aOptions,
    _i2.LinuxOptions? lOptions,
    _i2.WindowsOptions? wOptions,
    _i2.WebOptions? webOptions,
    _i2.MacOsOptions? mOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [],
          {
            #key: key,
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #wOptions: wOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
          },
        ),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>);

  @override
  Future<void> deleteAll({
    _i2.IOSOptions? iOptions,
    _i2.AndroidOptions? aOptions,
    _i2.LinuxOptions? lOptions,
    _i2.WindowsOptions? wOptions,
    _i2.WebOptions? webOptions,
    _i2.MacOsOptions? mOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteAll,
          [],
          {
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #wOptions: wOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
          },
        ),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>);

  @override
  Future<Map<String, String>> readAll({
    _i2.IOSOptions? iOptions,
    _i2.AndroidOptions? aOptions,
    _i2.LinuxOptions? lOptions,
    _i2.WindowsOptions? wOptions,
    _i2.WebOptions? webOptions,
    _i2.MacOsOptions? mOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #readAll,
          [],
          {
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #wOptions: wOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
          },
        ),
        returnValue: Future<Map<String, String>>.value(<String, String>{}),
      ) as Future<Map<String, String>>);

  @override
  Future<bool> containsKey({
    required String? key,
    _i2.IOSOptions? iOptions,
    _i2.AndroidOptions? aOptions,
    _i2.LinuxOptions? lOptions,
    _i2.WindowsOptions? wOptions,
    _i2.WebOptions? webOptions,
    _i2.MacOsOptions? mOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #containsKey,
          [],
          {
            #key: key,
            #iOptions: iOptions,
            #aOptions: aOptions,
            #lOptions: lOptions,
            #wOptions: wOptions,
            #webOptions: webOptions,
            #mOptions: mOptions,
          },
        ),
        returnValue: Future<bool>.value(false),
      ) as Future<bool>);
}

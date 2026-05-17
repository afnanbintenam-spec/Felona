# FeloNa Developer Guide 🚀

This guide will help you understand the codebase structure and start contributing to FeloNa.

---

## 📚 Table of Contents

1. [Project Structure](#project-structure)
2. [Architecture Overview](#architecture-overview)
3. [State Management](#state-management)
4. [Adding a New Feature](#adding-a-new-feature)
5. [Creating Reusable Widgets](#creating-reusable-widgets)
6. [API Integration](#api-integration)
7. [Testing Guidelines](#testing-guidelines)
8. [Common Patterns](#common-patterns)

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Color palette
│   │   ├── app_text_styles.dart     # Typography
│   │   ├── app_theme.dart           # Theme configuration
│   │   └── enums.dart               # All enumerations
│   ├── errors/
│   │   ├── exceptions.dart          # Custom exceptions
│   │   └── failures.dart            # Failure classes
│   ├── network/
│   │   ├── api_client.dart          # Dio HTTP client
│   │   └── secure_storage_service.dart  # Secure storage
│   ├── di/
│   │   └── injection_container.dart # Dependency injection
│   └── widgets/                     # Reusable UI components
│       ├── buttons/
│       ├── cards/
│       ├── inputs/
│       └── ...
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/         # API & local data sources
│       │   ├── models/              # Data models (JSON)
│       │   └── repositories/        # Repository implementations
│       ├── domain/
│       │   ├── entities/            # Business entities
│       │   ├── repositories/        # Repository interfaces
│       │   └── usecases/            # Business logic
│       └── presentation/
│           ├── bloc/                # BLoC (events, states, bloc)
│           ├── pages/               # Screens
│           └── widgets/             # Feature-specific widgets
└── main.dart
```

---

## 🏗️ Architecture Overview

### Clean Architecture Layers

```
Presentation Layer (UI)
    ↓
Domain Layer (Business Logic)
    ↓
Data Layer (Data Sources)
```

### Dependency Rule
- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** depends on nothing (pure Dart)

### Example Flow

```
User Action (UI)
    ↓
BLoC Event
    ↓
Use Case
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Data Source (API/Local)
    ↓
Model → Entity
    ↓
BLoC State
    ↓
UI Update
```

---

## 🎯 State Management

### BLoC Pattern

We use the BLoC (Business Logic Component) pattern for state management.

#### 1. Define Events

```dart
// lib/features/[feature]/presentation/bloc/[feature]_event.dart

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object?> get props => [email, password];
}
```

#### 2. Define States

```dart
// lib/features/[feature]/presentation/bloc/[feature]_state.dart

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  
  const Authenticated({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
```

#### 3. Implement BLoC

```dart
// lib/features/[feature]/presentation/bloc/[feature]_bloc.dart

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  
  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }
}
```

#### 4. Use in UI

```dart
// In your screen widget

BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    
    return YourUIWidget();
  },
)

// Trigger event
context.read<AuthBloc>().add(
  LoginRequested(email: email, password: password),
);
```

---

## ➕ Adding a New Feature

### Step-by-Step Guide

#### 1. Create Feature Structure

```bash
lib/features/my_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

#### 2. Domain Layer (Business Logic)

**Entity** (Pure Dart class)
```dart
// lib/features/my_feature/domain/entities/my_entity.dart

class MyEntity extends Equatable {
  final String id;
  final String name;
  
  const MyEntity({
    required this.id,
    required this.name,
  });
  
  @override
  List<Object?> get props => [id, name];
}
```

**Repository Interface**
```dart
// lib/features/my_feature/domain/repositories/my_repository.dart

abstract class MyRepository {
  Future<Either<Failure, MyEntity>> getEntity(String id);
  Future<Either<Failure, List<MyEntity>>> getAllEntities();
}
```

**Use Case**
```dart
// lib/features/my_feature/domain/usecases/get_entity_usecase.dart

class GetEntityUseCase {
  final MyRepository repository;
  
  GetEntityUseCase(this.repository);
  
  Future<Either<Failure, MyEntity>> call(String id) {
    return repository.getEntity(id);
  }
}
```

#### 3. Data Layer

**Model** (with JSON serialization)
```dart
// lib/features/my_feature/data/models/my_model.dart

class MyModel extends MyEntity {
  const MyModel({
    required super.id,
    required super.name,
  });
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

**Data Source**
```dart
// lib/features/my_feature/data/datasources/my_remote_datasource.dart

abstract class MyRemoteDataSource {
  Future<MyModel> getEntity(String id);
}

class MyRemoteDataSourceImpl implements MyRemoteDataSource {
  final ApiClient apiClient;
  
  MyRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<MyModel> getEntity(String id) async {
    final response = await apiClient.get('/entities/$id');
    return MyModel.fromJson(response.data);
  }
}
```

**Repository Implementation**
```dart
// lib/features/my_feature/data/repositories/my_repository_impl.dart

class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  
  MyRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<Either<Failure, MyEntity>> getEntity(String id) async {
    try {
      final entity = await remoteDataSource.getEntity(id);
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
```

#### 4. Presentation Layer

Create BLoC (events, states, bloc) as shown in [State Management](#state-management).

**Screen**
```dart
// lib/features/my_feature/presentation/pages/my_screen.dart

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBloc()..add(LoadDataRequested()),
      child: Scaffold(
        appBar: AppBar(title: Text('My Feature')),
        body: BlocBuilder<MyBloc, MyState>(
          builder: (context, state) {
            if (state is MyLoading) {
              return CircularProgressIndicator();
            } else if (state is MyLoaded) {
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(state.items[index].name),
                  );
                },
              );
            } else if (state is MyError) {
              return Text('Error: ${state.message}');
            }
            return Container();
          },
        ),
      ),
    );
  }
}
```

#### 5. Register Dependencies

```dart
// lib/core/di/injection_container.dart

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Data sources
  sl.registerLazySingleton<MyRemoteDataSource>(
    () => MyRemoteDataSourceImpl(sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<MyRepository>(
    () => MyRepositoryImpl(sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetEntityUseCase(sl()));
  
  // BLoCs
  sl.registerFactory(() => MyBloc(getEntityUseCase: sl()));
}
```

---

## 🎨 Creating Reusable Widgets

### Button Example

```dart
// lib/core/widgets/buttons/custom_button.dart

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(text),
      ),
    );
  }
}
```

### Usage

```dart
CustomButton(
  text: 'Submit',
  onPressed: () => _handleSubmit(),
  isLoading: state is Loading,
)
```

---

## 🌐 API Integration

### API Client Setup

```dart
// lib/core/network/api_client.dart

class ApiClient {
  final Dio _dio;
  
  ApiClient() : _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.felona.com',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ),
  ) {
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
  }
  
  Future<Response> get(String path) async {
    return await _dio.get(path);
  }
  
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
}
```

### Making API Calls

```dart
// In your data source

Future<List<MyModel>> getItems() async {
  try {
    final response = await apiClient.get('/items');
    final List<dynamic> data = response.data;
    return data.map((json) => MyModel.fromJson(json)).toList();
  } on DioException catch (e) {
    throw ServerException(message: e.message ?? 'Server error');
  }
}
```

---

## 🧪 Testing Guidelines

### Unit Test Example

```dart
// test/features/my_feature/domain/usecases/get_entity_usecase_test.dart

void main() {
  late GetEntityUseCase useCase;
  late MockMyRepository mockRepository;
  
  setUp(() {
    mockRepository = MockMyRepository();
    useCase = GetEntityUseCase(mockRepository);
  });
  
  test('should return entity when repository call is successful', () async {
    // Arrange
    final entity = MyEntity(id: '1', name: 'Test');
    when(mockRepository.getEntity('1'))
        .thenAnswer((_) async => Right(entity));
    
    // Act
    final result = await useCase('1');
    
    // Assert
    expect(result, Right(entity));
    verify(mockRepository.getEntity('1'));
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### BLoC Test Example

```dart
// test/features/my_feature/presentation/bloc/my_bloc_test.dart

void main() {
  late MyBloc bloc;
  late MockGetEntityUseCase mockUseCase;
  
  setUp(() {
    mockUseCase = MockGetEntityUseCase();
    bloc = MyBloc(getEntityUseCase: mockUseCase);
  });
  
  blocTest<MyBloc, MyState>(
    'emits [MyLoading, MyLoaded] when LoadDataRequested is added',
    build: () {
      when(mockUseCase('1'))
          .thenAnswer((_) async => Right(MyEntity(id: '1', name: 'Test')));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadDataRequested(id: '1')),
    expect: () => [
      MyLoading(),
      MyLoaded(entity: MyEntity(id: '1', name: 'Test')),
    ],
  );
}
```

---

## 🔧 Common Patterns

### Error Handling

```dart
try {
  final result = await apiCall();
  return Right(result);
} on ServerException catch (e) {
  return Left(ServerFailure(message: e.message));
} on NetworkException {
  return Left(NetworkFailure(message: 'No internet connection'));
} catch (e) {
  return Left(UnknownFailure(message: e.toString()));
}
```

### Loading States

```dart
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    if (state is MyLoading) {
      return Center(child: CircularProgressIndicator());
    }
    // ... other states
  },
)
```

### Form Validation

```dart
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}
```

---

## 📝 Code Style Guidelines

1. **Naming Conventions**
   - Classes: `PascalCase`
   - Variables/Functions: `camelCase`
   - Constants: `camelCase` with `const`
   - Files: `snake_case.dart`

2. **Documentation**
   - Add doc comments for public APIs
   - Use `///` for documentation
   - Explain complex logic with inline comments

3. **Formatting**
   - Run `dart format .` before committing
   - Max line length: 80 characters
   - Use trailing commas for better formatting

4. **Imports**
   - Group imports: Dart SDK → Flutter → Packages → Project
   - Use relative imports within features
   - Use absolute imports across features

---

## 🚀 Quick Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Format code
dart format .

# Analyze code
flutter analyze

# Generate code (for build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# Clean build
flutter clean
```

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library](https://bloclibrary.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

**Happy Coding! 🎉**

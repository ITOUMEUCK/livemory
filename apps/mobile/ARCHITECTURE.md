# 🏗️ Architecture Technique - Livemory Mobile

## Vue d'Ensemble

Livemory est une application Flutter cross-platform suivant une **architecture clean en couches** avec séparation des responsabilités et gestion d'état centralisée.

---

## 🎯 Principes Architecturaux

### 1. Clean Architecture
Séparation en couches indépendantes:
- **Presentation Layer**: UI, Widgets, Screens
- **Domain Layer**: Business logic, Use cases, Entities
- **Data Layer**: Repository pattern, API calls, Local storage

### 2. SOLID Principles
- **Single Responsibility**: Chaque classe a une seule raison de changer
- **Open/Closed**: Extension sans modification
- **Liskov Substitution**: Polymorphisme respecté
- **Interface Segregation**: Interfaces spécifiques
- **Dependency Inversion**: Dépendances vers abstractions

### 3. Design Patterns
- **Repository Pattern**: Abstraction accès données
- **Provider Pattern**: State management (migration Riverpod prévue)
- **Factory Pattern**: Création objets complexes
- **Singleton**: Services globaux (API, Storage)
- **Observer Pattern**: Notifications, real-time updates

---

## 📦 Structure du Projet

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp configuration
│
├── core/                              # Fonctionnalités transversales
│   ├── constants/
│   │   ├── api_constants.dart         # URLs, endpoints
│   │   ├── app_constants.dart         # Configs app
│   │   └── storage_keys.dart          # Clés SharedPreferences
│   ├── errors/
│   │   ├── exceptions.dart            # Custom exceptions
│   │   └── failures.dart              # Error handling
│   ├── network/
│   │   ├── api_client.dart            # Dio configuration
│   │   └── network_info.dart          # Connectivity check
│   ├── theme/
│   │   ├── app_theme.dart             # Theme definition
│   │   ├── colors.dart                # Color palette
│   │   └── text_styles.dart           # Typography
│   └── utils/
│       ├── date_formatter.dart        # Date utilities
│       ├── validators.dart            # Form validation
│       └── extensions.dart            # Dart extensions
│
├── features/                          # Features modulaires
│   │
│   ├── auth/                          # Authentification
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── token_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── onboarding_screen.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── social_auth_buttons.dart
│   │
│   ├── groups/                        # Gestion groupes
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── group_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── group_model.dart
│   │   │   │   └── member_model.dart
│   │   │   └── repositories/
│   │   │       └── group_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── group.dart
│   │   │   │   └── member.dart
│   │   │   ├── repositories/
│   │   │   │   └── group_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_group_usecase.dart
│   │   │       ├── get_groups_usecase.dart
│   │   │       ├── invite_member_usecase.dart
│   │   │       └── update_member_role_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── group_provider.dart
│   │       ├── screens/
│   │       │   ├── group_list_screen.dart
│   │       │   ├── group_detail_screen.dart
│   │       │   ├── group_create_screen.dart
│   │       │   └── group_settings_screen.dart
│   │       └── widgets/
│   │           ├── group_card.dart
│   │           ├── member_list_item.dart
│   │           └── invite_button.dart
│   │
│   ├── events/                        # Gestion événements
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── event_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── event_model.dart
│   │   │   │   ├── event_template_model.dart
│   │   │   │   └── checklist_item_model.dart
│   │   │   └── repositories/
│   │   │       └── event_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── event.dart
│   │   │   │   ├── event_template.dart
│   │   │   │   └── checklist_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── event_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_event_usecase.dart
│   │   │       ├── get_events_usecase.dart
│   │   │       ├── update_event_usecase.dart
│   │   │       └── manage_checklist_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── event_provider.dart
│   │       ├── screens/
│   │       │   ├── event_list_screen.dart
│   │       │   ├── event_detail_screen.dart
│   │       │   ├── event_create_screen.dart
│   │       │   └── event_checklist_screen.dart
│   │       └── widgets/
│   │           ├── event_card.dart
│   │           ├── template_selector.dart
│   │           └── checklist_item_widget.dart
│   │
│   ├── polls/                         # Votes et sondages
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── poll_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── poll_model.dart
│   │   │   │   ├── poll_option_model.dart
│   │   │   │   └── vote_model.dart
│   │   │   └── repositories/
│   │   │       └── poll_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── poll.dart
│   │   │   │   ├── poll_option.dart
│   │   │   │   └── vote.dart
│   │   │   ├── repositories/
│   │   │   │   └── poll_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_poll_usecase.dart
│   │   │       ├── vote_usecase.dart
│   │   │       └── get_poll_results_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── poll_provider.dart
│   │       ├── screens/
│   │       │   ├── poll_create_screen.dart
│   │       │   ├── poll_vote_screen.dart
│   │       │   └── poll_results_screen.dart
│   │       └── widgets/
│   │           ├── poll_option_card.dart
│   │           └── poll_results_chart.dart
│   │
│   ├── budget/                        # Gestion budget
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── budget_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── expense_model.dart
│   │   │   │   └── balance_model.dart
│   │   │   └── repositories/
│   │   │       └── budget_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── expense.dart
│   │   │   │   └── balance.dart
│   │   │   ├── repositories/
│   │   │   │   └── budget_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_expense_usecase.dart
│   │   │       ├── calculate_balances_usecase.dart
│   │   │       └── export_budget_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── budget_provider.dart
│   │       ├── screens/
│   │       │   ├── budget_overview_screen.dart
│   │       │   ├── expense_add_screen.dart
│   │       │   └── balance_screen.dart
│   │       └── widgets/
│   │           ├── expense_card.dart
│   │           └── balance_chart.dart
│   │
│   ├── logistics/                     # Logistique & carte
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── location_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── location_model.dart
│   │   │   └── repositories/
│   │   │       └── logistics_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── location.dart
│   │   │   ├── repositories/
│   │   │   │   └── logistics_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_directions_usecase.dart
│   │   │       └── search_accommodations_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── logistics_provider.dart
│   │       ├── screens/
│   │       │   ├── map_screen.dart
│   │       │   ├── transport_screen.dart
│   │       │   └── accommodation_screen.dart
│   │       └── widgets/
│   │           ├── map_widget.dart
│   │           └── transport_option_card.dart
│   │
│   ├── notifications/                 # Notifications
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── notification_local_datasource.dart
│   │   │   │   └── notification_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── notification_model.dart
│   │   │   └── repositories/
│   │   │       └── notification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── notification.dart
│   │   │   ├── repositories/
│   │   │   │   └── notification_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_notifications_usecase.dart
│   │   │       └── mark_as_read_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── notification_provider.dart
│   │       ├── screens/
│   │       │   ├── notification_center_screen.dart
│   │       │   └── notification_settings_screen.dart
│   │       └── widgets/
│   │           └── notification_card.dart
│   │
│   └── profile/                       # Profil utilisateur
│       ├── data/
│       │   ├── datasources/
│       │   │   └── profile_remote_datasource.dart
│       │   ├── models/
│       │   │   └── profile_model.dart
│       │   └── repositories/
│       │       └── profile_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── profile.dart
│       │   ├── repositories/
│       │   │   └── profile_repository.dart
│       │   └── usecases/
│       │       ├── get_profile_usecase.dart
│       │       └── update_profile_usecase.dart
│       └── presentation/
│           ├── providers/
│           │   └── profile_provider.dart
│           ├── screens/
│           │   ├── profile_screen.dart
│           │   └── profile_edit_screen.dart
│           └── widgets/
│               ├── profile_header.dart
│               └── stats_widget.dart
│
└── shared/                            # Widgets partagés
    ├── widgets/
    │   ├── buttons/
    │   │   ├── primary_button.dart
    │   │   ├── secondary_button.dart
    │   │   └── icon_button.dart
    │   ├── cards/
    │   │   ├── base_card.dart
    │   │   └── image_card.dart
    │   ├── inputs/
    │   │   ├── text_field.dart
    │   │   ├── date_picker.dart
    │   │   └── dropdown.dart
    │   ├── navigation/
    │   │   ├── bottom_nav_bar.dart
    │   │   └── app_drawer.dart
    │   └── common/
    │       ├── loading_indicator.dart
    │       ├── error_widget.dart
    │       └── empty_state.dart
    └── models/
        └── result.dart                 # Result type (Success/Failure)
```

---

## 🔄 Flux de Données

### Architecture en Couches

```
┌─────────────────────────────────────────────────┐
│              PRESENTATION LAYER                  │
│  (Screens, Widgets, Providers)                  │
│  ↓ User interactions                            │
│  ↑ UI updates                                   │
└─────────────────────────────────────────────────┘
                      ↕
┌─────────────────────────────────────────────────┐
│              DOMAIN LAYER                        │
│  (Entities, Use Cases, Repository Interfaces)   │
│  ↓ Business logic execution                     │
│  ↑ Domain entities                              │
└─────────────────────────────────────────────────┘
                      ↕
┌─────────────────────────────────────────────────┐
│              DATA LAYER                          │
│  (Models, Repositories, Data Sources)           │
│  ↓ API calls / Local storage                    │
│  ↑ Raw data                                     │
└─────────────────────────────────────────────────┘
                      ↕
┌─────────────────────────────────────────────────┐
│         EXTERNAL (API, Database, Storage)       │
└─────────────────────────────────────────────────┘
```

### Exemple: Création d'un Événement

```
User tap "Create Event" button
     ↓
EventCreateScreen (Presentation)
     ↓
EventProvider.createEvent() (Presentation)
     ↓
CreateEventUseCase.call() (Domain)
     ↓
EventRepository.createEvent() (Domain Interface)
     ↓
EventRepositoryImpl.createEvent() (Data)
     ↓
EventRemoteDataSource.createEvent() (Data)
     ↓
ApiClient.post() (Core Network)
     ↓
Backend API
     ↑ Response
EventModel ← JSON
     ↑ Map to domain
Event entity
     ↑ Return result
Either<Failure, Event>
     ↑ Update state
Provider notifies listeners
     ↑ Rebuild UI
Screen shows success/error
```

---

## 🎛️ State Management (Provider)

### Architecture Provider

```dart
// 1. Provider definition
class EventProvider with ChangeNotifier {
  final CreateEventUseCase _createEventUseCase;
  
  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> createEvent(Event event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _createEventUseCase(event);
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (newEvent) {
        _events.add(newEvent);
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}

// 2. Usage in Screen
class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return LoadingIndicator();
        }
        
        if (provider.errorMessage != null) {
          return ErrorWidget(message: provider.errorMessage!);
        }
        
        return ListView.builder(
          itemCount: provider.events.length,
          itemBuilder: (context, index) {
            return EventCard(event: provider.events[index]);
          },
        );
      },
    );
  }
}
```

### Migration Riverpod (Prévue)

```dart
// Future state management avec Riverpod
@riverpod
class EventNotifier extends _$EventNotifier {
  @override
  Future<List<Event>> build() async {
    return ref.watch(getEventsUseCaseProvider).call();
  }
  
  Future<void> createEvent(Event event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createEventUseCaseProvider).call(event);
      return ref.read(getEventsUseCaseProvider).call();
    });
  }
}

// Usage
final eventProvider = ref.watch(eventNotifierProvider);

eventProvider.when(
  data: (events) => EventList(events: events),
  loading: () => LoadingIndicator(),
  error: (error, stack) => ErrorWidget(error: error),
);
```

---

## 🌐 Networking

### API Client (Dio)

```dart
class ApiClient {
  late Dio _dio;
  final AuthService _authService;
  
  ApiClient(this._authService) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = await _authService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 refresh token
          if (error.response?.statusCode == 401) {
            if (await _authService.refreshToken()) {
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
    
    // Logger (dev only)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }
  
  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
```

### Repository Pattern

```dart
// Domain interface
abstract class EventRepository {
  Future<Either<Failure, List<Event>>> getEvents();
  Future<Either<Failure, Event>> createEvent(Event event);
  Future<Either<Failure, Event>> updateEvent(Event event);
  Future<Either<Failure, void>> deleteEvent(String id);
}

// Data implementation
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  
  EventRepositoryImpl(this._remoteDataSource, this._networkInfo);
  
  @override
  Future<Either<Failure, List<Event>>> getEvents() async {
    if (await _networkInfo.isConnected) {
      try {
        final eventModels = await _remoteDataSource.getEvents();
        final events = eventModels.map((model) => model.toEntity()).toList();
        return Right(events);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
  
  // ... autres méthodes
}
```

---

## 💾 Local Storage

### Shared Preferences (Config Simple)

```dart
class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }
  
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }
  
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }
}
```

### SQLite (Données Complexes - À implémenter)

```dart
// Database helper pour cache offline
class DatabaseHelper {
  static const _dbName = 'livemory.db';
  static const _dbVersion = 1;
  
  Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        payer_id TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events (id)
      )
    ''');
  }
}
```

---

## 🔔 Real-Time (WebSockets)

### Socket.IO Client

```dart
class RealtimeService {
  IO.Socket? _socket;
  final AuthService _authService;
  
  RealtimeService(this._authService);
  
  Future<void> connect() async {
    final token = await _authService.getToken();
    
    _socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .build(),
    );
    
    _socket!.connect();
    
    _socket!.on('connect', (_) {
      print('Connected to real-time server');
    });
    
    _socket!.on('disconnect', (_) {
      print('Disconnected from real-time server');
    });
  }
  
  void listenToEvent(String eventName, Function(dynamic) callback) {
    _socket?.on(eventName, callback);
  }
  
  void emit(String eventName, dynamic data) {
    _socket?.emit(eventName, data);
  }
  
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
  }
}

// Usage dans un Provider
class EventProvider with ChangeNotifier {
  final RealtimeService _realtimeService;
  
  void subscribeToEventUpdates(String eventId) {
    _realtimeService.listenToEvent('event:$eventId:updated', (data) {
      final updatedEvent = Event.fromJson(data);
      _updateEventInList(updatedEvent);
      notifyListeners();
    });
  }
}
```

---

## 🔐 Authentification

### JWT Token Management

```dart
class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;
  
  String? _accessToken;
  String? _refreshToken;
  
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      _accessToken = response.data['accessToken'];
      _refreshToken = response.data['refreshToken'];
      
      await _storageService.saveToken(_accessToken!);
      await _storageService.saveRefreshToken(_refreshToken!);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> refreshToken() async {
    try {
      final response = await _apiClient.post('/auth/refresh', data: {
        'refreshToken': _refreshToken,
      });
      
      _accessToken = response.data['accessToken'];
      await _storageService.saveToken(_accessToken!);
      
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _storageService.clearToken();
    await _storageService.clearRefreshToken();
    _accessToken = null;
    _refreshToken = null;
  }
  
  String? getToken() => _accessToken;
  bool get isAuthenticated => _accessToken != null;
}
```

### Social Auth (Google, Apple)

```dart
class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // Send to backend for verification
      final response = await _apiClient.post('/auth/google', data: {
        'idToken': googleAuth.idToken,
        'accessToken': googleAuth.accessToken,
      });
      
      return response.data;
    } catch (e) {
      print('Google Sign In error: $e');
      return null;
    }
  }
  
  Future<UserCredential?> signInWithApple() async {
    // Similar implementation for Apple Sign In
  }
}
```

---

## 📱 Navigation

### Router Configuration

```dart
// routes.dart
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const groupDetail = '/group/:id';
  static const eventDetail = '/event/:id';
  static const eventCreate = '/event/create';
  static const pollCreate = '/poll/create';
  static const budgetOverview = '/budget/:eventId';
  static const profile = '/profile';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case groupDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => GroupDetailScreen(groupId: id),
        );
      // ... autres routes
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
```

---

## 🧪 Testing Strategy

### Structure Tests

```
test/
├── unit/                              # Tests unitaires
│   ├── core/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   └── domain/
│   │   │       └── usecases/
│   │   └── events/
│   └── mocks/
│
├── widget/                            # Tests widgets
│   ├── screens/
│   └── widgets/
│
└── integration/                       # Tests d'intégration
    └── flows/
```

### Exemples de Tests

```dart
// unit_test
void main() {
  late CreateEventUseCase useCase;
  late MockEventRepository mockRepository;
  
  setUp(() {
    mockRepository = MockEventRepository();
    useCase = CreateEventUseCase(mockRepository);
  });
  
  test('should create event successfully', () async {
    // Arrange
    final event = Event(title: 'Test Event', date: DateTime.now());
    when(mockRepository.createEvent(event))
        .thenAnswer((_) async => Right(event));
    
    // Act
    final result = await useCase(event);
    
    // Assert
    expect(result, Right(event));
    verify(mockRepository.createEvent(event));
    verifyNoMoreInteractions(mockRepository);
  });
}

// widget_test
void main() {
  testWidgets('EventCard displays event title', (tester) async {
    // Arrange
    final event = Event(title: 'Test Event', date: DateTime.now());
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventCard(event: event),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Test Event'), findsOneWidget);
  });
}
```

---

## 🚀 Performance Optimization

### Lazy Loading

```dart
// Pagination pour listes longues
class EventListProvider with ChangeNotifier {
  final GetEventsUseCase _getEventsUseCase;
  
  List<Event> _events = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    final result = await _getEventsUseCase(page: _currentPage);
    
    result.fold(
      (failure) {
        _isLoading = false;
        notifyListeners();
      },
      (newEvents) {
        _events.addAll(newEvents);
        _currentPage++;
        _hasMore = newEvents.length >= 20; // Page size
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
```

### Image Caching

```dart
// Utilisation de cached_network_image
CachedNetworkImage(
  imageUrl: event.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  cacheManager: CustomCacheManager.instance,
  maxWidthDiskCache: 1000,
  maxHeightDiskCache: 1000,
)
```

### Debouncing Search

```dart
class SearchProvider with ChangeNotifier {
  Timer? _debounce;
  String _searchQuery = '';
  List<Event> _searchResults = [];
  
  void updateSearchQuery(String query) {
    _searchQuery = query;
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }
  
  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    final results = await _searchEventsUseCase(_searchQuery);
    _searchResults = results;
    notifyListeners();
  }
}
```

---

## 📊 Analytics & Monitoring

### Firebase Analytics Integration

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }
  
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
  
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}

// Usage
analyticsService.logEvent('event_created', parameters: {
  'event_type': 'party',
  'participant_count': 10,
});
```

### Crash Reporting (Firebase Crashlytics)

```dart
class CrashReportingService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  Future<void> initialize() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
    
    FlutterError.onError = _crashlytics.recordFlutterFatalError;
    
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  void log(String message) {
    _crashlytics.log(message);
  }
  
  void setCustomKey(String key, dynamic value) {
    _crashlytics.setCustomKey(key, value);
  }
  
  void recordError(dynamic error, StackTrace? stackTrace) {
    _crashlytics.recordError(error, stackTrace);
  }
}
```

---

## 🔒 Security Best Practices

1. **Input Validation**: Toujours valider côté client ET serveur
2. **Sensitive Data**: Jamais en logs, utiliser secure storage
3. **API Keys**: Jamais en hardcoded, utiliser env variables
4. **HTTPS Only**: Forcer HTTPS pour toutes les requêtes
5. **Token Expiration**: Gérer refresh automatique
6. **Deep Link Security**: Valider tokens dans liens magiques
7. **Biometric Auth**: Optionnel pour quick login
8. **Certificate Pinning**: Pour prod (empêcher MITM)

---

## 📦 Build & Deployment

### Environment Configuration

```dart
// env_config.dart
enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment _environment = Environment.dev;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging.livemory.app/api';
      case Environment.prod:
        return 'https://api.livemory.app';
    }
  }
  
  static bool get enableLogging => _environment != Environment.prod;
}
```

### CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.4'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release --no-codesign
```

---

**Document créé le**: 15 décembre 2025  
**Version**: 1.0.0  
**Statut**: ✅ Architecture validée

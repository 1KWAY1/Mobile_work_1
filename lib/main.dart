import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Конфигурация Supabase
class SupabaseConfig {
  static const String supabaseUrl = 'https://mkicukrucvpejjcszqks.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1raWN1a3J1Y3ZwZWpqY3N6cWtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MjkwNTcsImV4cCI6MjA4MDEwNTA1N30.yaPfyij4Nw1bjmOEz1Wy9U1g4SVQxevRzcjUuQPX3PA';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Supabase
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthWrapper(), // Обертка для проверки аутентификации
    );
  }
}

// Обертка для проверки состояния аутентификации
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _supabase = SupabaseConfig.client;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();

    // Слушатель изменений аутентификации
    _supabase.auth.onAuthStateChange.listen((AuthState data) {
      final AuthChangeEvent event = data.event;
      print('Auth state changed: $event');

      if (event == AuthChangeEvent.signedIn) {
        setState(() {
          _currentUser = data.session?.user;
          _isLoading = false;
        });
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() {
          _currentUser = null;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      setState(() {
        _currentUser = session?.user;
        _isLoading = false;
      });
      print('Current user: ${session?.user?.email}');
    } catch (e) {
      print('Error getting current user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    print('Building AuthWrapper: user = ${_currentUser?.email}');

    if (_currentUser != null) {
      return const MainAppScreen();
    } else {
      return const LoginScreen();
    }
  }
}

// ЭКРАН АВТОРИЗАЦИИ
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _supabase = SupabaseConfig.client;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _supabase.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Успешный вход - навигация через AuthWrapper
      } on AuthException catch (e) {
        _showErrorDialog('Ошибка авторизации: ${e.message}');
      } catch (e) {
        _showErrorDialog('Произошла ошибка: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _showErrorDialog('Введите email для восстановления пароля');
      return;
    }

    try {
      await _supabase.auth.resetPasswordForEmail(_emailController.text);
      _showSuccessDialog('Инструкции по сбросу пароля отправлены на ваш email');
    } catch (e) {
      _showErrorDialog('Ошибка при восстановлении пароля: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Успешно'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Заголовок
                const Text(
                  'Вход в аккаунт',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Введите ваши данные для входа',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Поле для email/логина
                const Text(
                  'Email или логин',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Введите ваш email или логин',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите email или логин';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Поле для пароля
                const Text(
                  'Пароль',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Введите ваш пароль',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль должен содержать минимум 6 символов';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Забыли пароль
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text(
                      'Забыли пароль?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Кнопка входа
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Войти',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Разделитель
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'или',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 30),

                // Кнопки социальных сетей
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.facebook, color: Colors.blue[800], size: 32),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.g_mobiledata, color: Colors.red, size: 32),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.apple, color: Colors.black, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Ссылка на регистрацию
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Еще нет аккаунта? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Навигация на экран регистрации
                        },
                        child: const Text(
                          'Зарегистрироваться',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ГЛАВНОЕ ОКНО ПРИЛОЖЕНИЯ
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await SupabaseConfig.client.auth.signOut();
      // Навигация произойдет автоматически через AuthWrapper
    } catch (e) {
      print('Ошибка при выходе: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/img/logotip.png'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final size = MediaQuery.of(context).size;
          final width = size.width;
          final height = size.height;

          return Align(
            child: Container(
              width: width * 0.95,
              height: height * 0.85,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildImageItem('assets/img/vsevedushiy_chitatel.jpg', 'Точка зрения всеведущего читателя'),
                        _buildImageItem('assets/img/solo_up_leveling.jpg', 'Поднятие уровня в одиночку'),
                        _buildImageItem('assets/img/pick_me_up.jpg', 'Выбери меня'),
                        _buildImageItem('assets/img/ya_ne_talantliviy.jpg', 'Я не талантливый'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildImageItem(String imagePath, String caption) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Image.asset(
          imagePath,
          width: 150,
          height: 200,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 15),
        Text(
          caption,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
import 'package:flutter/material.dart';

import 'signup_tip_service.dart';

void main() {
  runApp(const MyApp());
}

// Great-grandparent widget for the whole app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fun Signup App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Lets the Sign Up button check all the fields at once.
  final _formKey = GlobalKey<FormState>();

  // These keep track of what the user types.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // No instructor endpoint was provided, so this creates the mock service.
  final SignupTipService _tipService = createSignupTipService();
  bool _loadingTip = false;
  bool _showTipError = false;
  String? _tip;

  String get _tipButtonLabel {
    if (_loadingTip) {
      return 'Getting a tip...';
    }
    if (_showTipError) {
      return 'Try again';
    }
    if (_tip != null) {
      return 'Get another tip';
    }
    return 'Get a signup tip';
  }

  Future<void> _getTip({bool previewError = false}) async {
    setState(() {
      _loadingTip = true;
      _showTipError = false;
      _tip = null;
    });

    try {
      // This only exists so the mock offline state can be shown in class.
      if (previewError) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        throw const SignupTipException();
      }

      final tip = await _tipService.fetchTip();
      if (!mounted) return;
      setState(() {
        _loadingTip = false;
        _tip = shortenTip(tip);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingTip = false;
        _showTipError = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Us Today for the Cash Money!'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Sign Up button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Demo signup complete - your form passed validation!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Task A: a small AI tip feature that is separate from validation.
              Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'AI Signup Coach',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_tipService.isMock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'MOCK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Get one password tip. Your name, email, and password are never sent.',
                style: TextStyle(color: Colors.black54),
              ),
              if (_tipService.isMock) ...[
                const SizedBox(height: 4),
                const Text(
                  'Mock mode - no live model is called.',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('tip-button'),
                onPressed: _loadingTip ? null : _getTip,
                icon: _loadingTip
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lightbulb_outline),
                label: Text(_tipButtonLabel),
              ),
              if (_tip != null) ...[
                const SizedBox(height: 12),
                Container(
                  key: const Key('tip-result'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI-generated suggestion',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(_tip!),
                    ],
                  ),
                ),
              ],
              if (_showTipError) ...[
                const SizedBox(height: 12),
                Container(
                  key: const Key('tip-error'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Could not reach the AI coach. '
                    'Check your connection and try again.',
                  ),
                ),
              ],
              if (_tipService.isMock)
                TextButton(
                  onPressed: _loadingTip
                      ? null
                      : () => _getTip(previewError: true),
                  child: const Text('Preview offline error (mock)'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

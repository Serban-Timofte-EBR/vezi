import 'package:flutter/material.dart';
import 'package:vezi/features/auth/services/auth_service.dart';
import 'package:vezi/features/launcher/presentation/launcher_page.dart';

class VerifyCodePage extends StatefulWidget {
  final String uid;

  const VerifyCodePage({required this.uid, super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCodeCtrl = TextEditingController();
  final _smsCodeCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  void _verify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await _authService.verifyUserCodes(
      uid: widget.uid,
      otpCode: _emailCodeCtrl.text.trim(),
      smsCode: _smsCodeCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _loading = false);

      final snackBar = SnackBar(content: Text(result['message']));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (result['success']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LauncherPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Verificare cont')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Introdu codurile de verificare",
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailCodeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cod primit pe email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Codul este necesar'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _smsCodeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cod primit prin SMS',
                  prefixIcon: Icon(Icons.sms),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Codul este necesar'
                    : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _verify,
                  icon: const Icon(Icons.verified),
                  label: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Verifică contul"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

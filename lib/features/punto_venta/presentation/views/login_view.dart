import 'package:edsuite/core/extensions/context_extensions.dart';
import 'package:edsuite/core/widgets/language_selector.dart';
import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:edsuite/features/punto_venta/presentation/validators/user_validator.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../bloc/user/user_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final formKey = GlobalKey<FormState>();
  String code = '';

  void _loginWithCode(BuildContext context) {
    if (!formKey.currentState!.validate()) return;
    final posBloc = context.read<PosBloc>().state;
    context.read<UserBloc>().add(
      LoginWithCodeEvent(
        baseUrl: posBloc.baseUrl,
        code: code, // código del formulario
        solicitarMontoApertura: _solicitarMontoApertura,
      ),
    );
  }

  Future<String?> _solicitarMontoApertura(String nombre) async {
    final TextEditingController _montoController = TextEditingController();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF1F9FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'APERTURA',
              style: context.theme.textTheme.headlineMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              nombre.toUpperCase(),
              style: context.theme.textTheme.titleLarge?.copyWith(
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  labelText: 'MONTO INICIAL',
                  labelStyle: context.theme.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: context.colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: context.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(14),
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      final monto = _montoController.text.trim();
                      if (monto.isEmpty || double.tryParse(monto) == null)
                        return;
                      Navigator.pop(context, monto);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      'Confirmar',
                      style: context.theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoPassword() async {
    final TextEditingController _passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingrese la contraseña'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (_passwordController.text == 'escienza2025**') {
                Navigator.pop(context, true);
              } else {
                CustomDialog.showSnackbar(
                  context,
                  "Contraseña incorrecta",
                  true,
                );
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.push('/configuracionPOS');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<UserBloc>().state.status == UserStatus.loginInProgress;
    return Form(
      key: formKey,

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: context.screenHeight * 0.1,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.controlCenterTitle,
                  style: context.theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.selectOptionToContinue,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                LanguageSelector(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 40,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.idCard,
                    size: 60,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.rfidOrCodeInstruction,
                    style: context.theme.textTheme.labelMedium?.copyWith(
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    onFieldSubmitted: (value) => _loginWithCode(context),
                    onChanged: (value) => setState(() => code = value),
                    enabled: !isLoading,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                        UserValidator.userWithContext(context, value),
                    decoration: InputDecoration(
                      labelText: context.l10n.accessCodeLabel,
                      floatingLabelStyle: TextStyle(
                        color: context.colorScheme.primary,
                      ),
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: context.colorScheme.primary,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isLoading) const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Powered by Edsuite',
                          style: context.theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black38,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.black38,
                          ),
                          onPressed: _mostrarDialogoPassword,
                          tooltip: 'Configuración',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:edsuite/core/extensions/extensions.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../bloc/pos/pos_bloc.dart';

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  String _selectedProtocol = 'http';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosBloc>().add(const GetPosEntity());
    });
  }

  Future<void> _saveConfiguration() async {
    final protocol = _selectedProtocol;
    final server = _serverController.text.trim();

    if (server.isEmpty) {
      CustomDialog.showSnackbar(context, context.l10n.enterServerError, true);
      return;
    }

    final fullUrl = '$protocol://$server';

    context.read<PosBloc>().add(SetBaseUrl(fullUrl));
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim();
    final baseUrl = context.read<PosBloc>().state.baseUrl;

    if (baseUrl.isEmpty) {
      CustomDialog.showSnackbar(
        context,
        context.l10n.configureServerFirstError,
        true,
      );
      return;
    }

    if (code.isEmpty) {
      CustomDialog.showSnackbar(
        context,
        context.l10n.enterActivationCodeError,
        true,
      );
      return;
    }

    context.read<PosBloc>().add(SetPosCode(code));
  }

  void _handlePosStatusSuccess(PosState state) {
    if (state.state == 1) {
      if (state.type == 'AUTO') {
        context.go('/welcome');
      } else if (state.type == 'PV') {
        context.go('/home');
      } else {
        CustomDialog.showSnackbar(
          context,
          context.l10n.unknownPosTypeError,
          true,
        );
      }
    } else if (state.state == 0) {
      CustomDialog.showSnackbar(
        context,
        context.l10n.posDeactivatedError,
        true,
      );
    }
  }

  void _handlePosStatusSuccessCode(PosState state) {
    if (state.state == 0) {
      CustomDialog.showSnackbar(context, context.l10n.posInactiveError, true);
    } else {
      if (state.type == 'AUTO') {
        context.go('/welcome');
      } else if (state.type == 'PV') {
        context.go('/home');
      } else {
        CustomDialog.showSnackbar(
          context,
          context.l10n.unknownPosTypeError,
          true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final posState = context.watch<PosBloc>().state.status;
    return BlocListener<PosBloc, PosState>(
      listener: (context, state) {
        switch (state.status) {
          case PosStatus.success:
            _handlePosStatusSuccess(state);
            break;
          case PosStatus.successBaseUrl:
            CustomDialog.showSnackbar(
              context,
              context.l10n.connectionSuccessMessage,
              false,
            );
            break;
          case PosStatus.successCode:
            _handlePosStatusSuccessCode(state);
            break;
          case PosStatus.failed:
            CustomDialog.showSnackbar(
              context,
              getErrorMessage(state.failure!, context),
              true,
            );
            break;
          default:
            break;
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Center(
            child: posState == PosStatus.loading
                ? const CircularProgressIndicator(strokeWidth: 3)
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.screenWidth * 0.05,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        _buildTopHeader(),
                        const SizedBox(height: 30),
                        _buildCardConfig(context, posState),
                        const SizedBox(height: 30),
                        _buildCardCodeActivate(posState),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  SizedBox _buildCardCodeActivate(PosStatus posState) {
    return SizedBox(
      width: double.maxFinite,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.activationCodeTitle,
                style: context.theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                enabled: posState != PosStatus.loadingCode,
                onSubmitted: (_) => _validateCode(),
                cursorColor: Colors.blue,
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  letterSpacing: 1.5,
                ),

                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.theme.primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: context.theme.primaryColor,
                      width: 2,
                    ),
                  ),
                  hintText: context.l10n.activationCodeHint,
                  hintStyle: context.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _buildCardConfig(BuildContext context, PosStatus posState) {
    return SizedBox(
      width: double.maxFinite,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black.withValues(alpha: 0.4),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.serverConfigurationTitle,
                style: context.theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.theme.inputDecorationTheme.fillColor,
                      border: Border.all(
                        color:
                            context
                                .theme
                                .inputDecorationTheme
                                .enabledBorder
                                ?.borderSide
                                .color ??
                            Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedProtocol,
                      underline: const SizedBox(),
                      dropdownColor: context.theme.popupMenuTheme.color,
                      style: context.theme.textTheme.bodyMedium,
                      onChanged: (value) =>
                          setState(() => _selectedProtocol = value!),
                      items: ['http', 'https'].map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(
                            p.toUpperCase(),
                            style: context.theme.textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _serverController,
                      decoration: InputDecoration(
                        hintText: context.l10n.ipOrDomainHint,
                        hintStyle: context.theme.textTheme.bodyMedium,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: posState == PosStatus.loadingBaseUrl
                    ? null
                    : _saveConfiguration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: posState == PosStatus.loadingBaseUrl
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        context.l10n.validateServerButton,
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildTopHeader() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Align(alignment: Alignment.topRight, child: const LanguageSelector()),
          Image.asset(
            'assets/images/logo.png',
            height: context.screenHeight * 0.1,
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.posConfigurationTitle,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

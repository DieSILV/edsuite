import 'package:edsuite/core/extensions/extensions.dart';
import 'package:edsuite/core/helpers/get_error_msg_icon.dart';
import 'package:edsuite/features/niubiz/presentation/niubiz_bloc/niubiz_bloc.dart';
import 'package:edsuite/features/payment/presentation/bloc/payment_punto_venta/payment_punto_venta_bloc.dart';
import 'package:edsuite/features/punto_venta/presentation/bloc/user/user_bloc.dart';
import 'package:edsuite/features/punto_venta/presentation/bloc/user_actions/user_actions_bloc.dart';
import 'package:edsuite/features/punto_venta/presentation/views/user_view.dart';
import 'package:edsuite/features/punto_venta/presentation/views/views.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(const LoadSessionEvent());
      //Clear states
      context.read<UserActionBloc>().add(const UserActionsClearEvent());
      context.read<NiubizBloc>().add(const NiubizClearEvent());
      context.read<PaymentPuntoVentaBloc>().add(const ClearDataPayment());
    });
  }

  @override
  Widget build(BuildContext context) {
    final userStatus = context.watch<UserBloc>().state.status;
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          switch (state.status) {
            case UserStatus.loginSuccess:
              CustomDialog.showSnackbar(
                context,
                context.l10n.welcomeUser(
                  state.userData?.name ?? context.l10n.defaultUserName,
                ),
              );
            case UserStatus.failed:
              CustomDialog.showSnackbar(
                context,
                getErrorMessage(state.failure!, context),
                true,
              );
              break;
            default:
          }
        },
        child: SafeArea(
          child: userStatus == UserStatus.loginSuccess
              ? UserView()
              : LoginView(),
        ),
      ),
      bottomNavigationBar: userStatus == UserStatus.loginSuccess
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<UserBloc>().add(const LogoutEvent());
                  context.go("/");
                },
                icon: const Icon(Icons.logout),
                label: Text(
                  context.l10n.closeSession,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: context.theme.textTheme.bodyMedium,
                ),
              ),
            )
          : null,
    );
  }
}

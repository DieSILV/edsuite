import 'package:edsuite/core/extensions/context_extensions.dart';
import 'package:edsuite/features/punto_venta/data/data.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/user/user_bloc.dart';

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  void cerrarSesion(BuildContext context) async {
    context.read<UserBloc>().add(const LogoutEvent());
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;

    return Scaffold(
      //backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                child: userState.turnoData != null
                    ? _buildOpenShiftView(
                        context,
                        userState.userData!,
                        userState.turnoData!,
                      )
                    : Center(
                        child: Text(
                          context.l10n.noOpenShift,
                          style: context.theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () => cerrarSesion(context),
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
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: context.theme.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          Text(
            context.l10n.shiftManagementTitle,
            style: context.theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenShiftView(
    BuildContext context,
    UserModel user,
    TurnoModel turno,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.greetingMessage(
            user.name ?? context.l10n.defaultUserName,
          ),
          style: context.theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.activeShiftLabel(
            _formatDate(turno.fechaLlegada, context),
          ),
          style: context.theme.textTheme.bodyLarge,
        ),
        Text(
          context.l10n.initialAmountLabel(turno.montoLlegada ?? 'n/a'),
          style: context.theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        Expanded(child: _buildShiftOptions(context, user, turno)),
      ],
    );
  }

  Widget _buildShiftOptions(
    BuildContext context,
    UserModel user,
    TurnoModel turno,
  ) {
    final opciones = [
      {'icon': FontAwesomeIcons.receipt, 'label': context.l10n.viewSalesOption},
      {'icon': FontAwesomeIcons.vault, 'label': context.l10n.vaultOption},
      {
        'icon': FontAwesomeIcons.moneyBillWave,
        'label': context.l10n.expensesOption,
      },
      {
        'icon': FontAwesomeIcons.powerOff,
        'label': context.l10n.closeShiftOption,
      },
      {
        'icon': FontAwesomeIcons.solidCreditCard,
        'label': context.l10n.niubizOption,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      children: opciones.map((item) {
        return Material(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          elevation: 3,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              /* switch (item['label']) {
                case 'Gastos':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExpenseScreen(usuarioId: usuarioId, turnoId: turnoId),
                    ),
                  );
                  break;
                case 'Bóveda':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VaultsScreen(usuarioId: usuarioId, turnoId: turnoId),
                    ),
                  );
                  break;
                case 'Ver Ventas':
                  Navigator.pushNamed(
                    context,
                    'Ventas',
                    arguments: {'usuarioId': usuarioId, 'turnoId': turnoId},
                  );
                  break;
                case 'Cerrar Turno':
                  Navigator.pushNamed(
                    context,
                    'Cierre',
                    arguments: {'usuarioId': usuarioId, 'turnoId': turnoId},
                  );
                  break;
                case 'Niubiz':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NiubizScreen(),
                    ),
                  );
                  break;
                default:
                  _showAlert('Info', '${item['label']} no implementado.');
              } */
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  item['icon'] as IconData,
                  color: context.theme.primaryColor,
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'] as String,
                  style: context.theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(dynamic fechaUtc, BuildContext context) {
    if (fechaUtc == null) {
      return context.l10n.dateUnavailable;
    }

    try {
      DateTime fecha;

      // Si ya es un DateTime, usarlo directamente
      if (fechaUtc is DateTime) {
        fecha = fechaUtc.toLocal();
      }
      // Si es un String, parsearlo
      else if (fechaUtc is String) {
        if (fechaUtc.isEmpty) {
          return context.l10n.dateUnavailable;
        }
        fecha = DateTime.parse(fechaUtc).toLocal();
      }
      // Si es otro tipo, intentar convertirlo a String y parsearlo
      else {
        fecha = DateTime.parse(fechaUtc.toString()).toLocal();
      }

      final dia = '${fecha.day}'.padLeft(2, '0');
      final mes = '${fecha.month}'.padLeft(2, '0');
      final anio = fecha.year;
      final hora = '${fecha.hour}'.padLeft(2, '0');
      final minuto = '${fecha.minute}'.padLeft(2, '0');
      return '$dia/$mes/$anio $hora:$minuto';
    } catch (e) {
      return context.l10n.dateInvalid;
    }
  }
}

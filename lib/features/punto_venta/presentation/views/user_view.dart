import 'package:edsuite/core/extensions/context_extensions.dart';
import 'package:edsuite/features/punto_venta/presentation/bloc/user/user_bloc.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserBloc>().state.userData!;

    final List<Map<String, dynamic>> options = [
      {
        'label': context.l10n.manageOption,
        'icon': FontAwesomeIcons.clock,
        'screen': '/gestionTurno',
      },
      {
        'label': context.l10n.sellOption,
        'icon': FontAwesomeIcons.cashRegister,
        'screen': '/ventasProgramada',
      },
      {
        'label': context.l10n.invoiceOption,
        'icon': FontAwesomeIcons.moneyBillWave,
        'screen': '/ventasLibres',
      },
      {
        'label': context.l10n.marketOption,
        'icon': FontAwesomeIcons.calendarDays,
        'screen': '/ventas',
      },
    ];
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(
                  context.l10n.controlCenterTitle,
                  style: context.theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.personalLabel(
                    userData.name ?? context.l10n.defaultUserName,
                  ),
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                LanguageSelector(),
                const SizedBox(height: 20),
                GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: options.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = options[index];
                    return InkWell(
                      onTap: () => context.push(item['screen']),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              item['icon'],
                              size: 32,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['label'],
                              textAlign: TextAlign.center,
                              style: context.theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

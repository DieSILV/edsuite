import 'package:edsuite/core/bloc/locale/locale_bloc.dart';
import 'package:edsuite/core/utils/language.dart';
import 'package:edsuite_common/edsuite_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return PopupMenuButton<Language>(
          onSelected: (Language language) {
            context.read<LocaleBloc>().add(ChangeLanguage(language));
          },
          itemBuilder: (BuildContext context) =>
              Language.values.map((language) {
                return PopupMenuItem<Language>(
                  value: language,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(language.flag),
                      const SizedBox(width: 8),
                      Text(language.name),
                      if (state.selectedLanguage == language) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check, size: 16),
                      ],
                    ],
                  ),
                );
              }).toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.selectedLanguage.flag),
                const SizedBox(width: 4),
                Text(
                  state.selectedLanguage.name,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

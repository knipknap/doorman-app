import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PasswordFormField extends TextFormField {
  PasswordFormField({
    Key? key,
    required BuildContext context,
    TextEditingController? controller,
    String? title,
    Function(String)? onFieldSubmitted,
  }) : super(
    key: key,
    controller: controller,
    obscureText: true,
    autofillHints: const [AutofillHints.password],
    onFieldSubmitted: onFieldSubmitted,
    decoration: InputDecoration(
      labelText: (title?.isEmpty ?? true) ? AppLocalizations.of(context)!.password : title
    )
  );
}

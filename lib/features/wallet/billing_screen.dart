import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// Where withdrawals are paid. Only the user and admins can read it.
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  late final Future<BillingDetails> _details = ref
      .read(walletRepositoryProvider)
      .billing(ref.read(userIdProvider) ?? '')
      .then((d) {
        _name.text = d.fullName;
        _phone.text = d.whishPhone;
        return d;
      });
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final id = ref.read(userIdProvider);
    if (id == null) return;
    setState(() {
      _nameError = _name.text.trim().isEmpty ? l10n.nameMissing : null;
      _phoneError = switch (_phone.text.trim()) {
        '' => l10n.phoneMissing,
        final phone when !isPhoneNumber(phone) => l10n.phoneInvalid,
        _ => null,
      };
    });
    if (_nameError != null || _phoneError != null) return;
    try {
      await ref
          .read(walletRepositoryProvider)
          .saveBilling(
            id,
            BillingDetails(fullName: _name.text, whishPhone: _phone.text),
          );
      if (!mounted) return;
      showSnack(context, l10n.saved);
      context.pop();
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TitledPage(
      title: l10n.billingDetails,
      subtitle: l10n.billingSubtitle,
      bottom: BusyButton(label: l10n.save, onPressed: _save),
      children: [
        FutureBuilder(
          future: _details,
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                FieldLabel(
                  l10n.fullName,
                  child: TextField(
                    controller: _name,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      hintText: 'John Doe',
                      errorText: _nameError,
                    ),
                  ),
                ),
                FieldLabel(
                  l10n.whishNumber,
                  hint: l10n.whishNumberHint,
                  child: TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: InputDecoration(
                      hintText: '70 123 456',
                      errorText: _phoneError,
                    ),
                  ),
                ),
                Notice(message: l10n.billingPrivate, icon: Icons.lock_rounded),
              ],
            );
          },
        ),
      ],
    );
  }
}

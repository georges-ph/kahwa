import 'package:flutter/material.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';

class BillingDetailsScreen extends StatefulWidget {
  const BillingDetailsScreen({super.key});

  @override
  State<BillingDetailsScreen> createState() => _BillingDetailsScreenState();
}

class _BillingDetailsScreenState extends State<BillingDetailsScreen> {
  late Future<void> _details;

  final _whishPhoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _details = _load();
  }

  @override
  void dispose() {
    _whishPhoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final details = await balanceRepository.getBillingDetails(
      authRepository.userId,
    );
    _whishPhoneController.text = details.whishPhone;
    _firstNameController.text = details.firstName;
    _lastNameController.text = details.lastName;
    _phoneController.text = details.phone;
  }

  void _reload() => setState(() => _details = _load());

  Future<void> _save() async {
    final details = BillingDetails(
      whishPhone: _whishPhoneController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (details.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await balanceRepository.saveBillingDetails(
        authRepository.userId,
        details,
      );
      if (mounted) showSnack(context, 'Updated successfully');
    } catch (_) {
      if (mounted) showSnack(context, 'Could not save, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.settings,
      body: AsyncBody(
        future: _details,
        onRetry: _reload,
        builder: (context, _) {
          return PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle('Billing Details'),
                const SizedBox(height: 40),
                const Text('Payments are made through WHISH MONEY.'),
                const SizedBox(height: 24),
                InputText(
                  controller: _whishPhoneController,
                  title: 'Phone Number',
                  subtitle:
                      'Enter a phone number used with the WHISH app if '
                      'available.',
                  hint: '70 123 456',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _firstNameController,
                  title: 'Billing Information',
                  subtitle:
                      "If you don't have the WHISH app, you can enter the "
                      'information below and collect the money at any WHISH '
                      'agent.',
                  hint: 'First Name',
                  icon: Icons.person_rounded,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                InputText(
                  controller: _lastNameController,
                  hint: 'Last Name',
                  icon: Icons.person_rounded,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                InputText(
                  controller: _phoneController,
                  hint: 'Phone number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Save',
                  isLoading: _isLoading,
                  onPressed: _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

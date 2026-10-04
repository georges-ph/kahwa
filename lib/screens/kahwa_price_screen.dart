import 'package:flutter/material.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/kahwa_prices.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';

class KahwaPriceScreen extends StatefulWidget {
  const KahwaPriceScreen({super.key});

  @override
  State<KahwaPriceScreen> createState() => _KahwaPriceScreenState();
}

class _KahwaPriceScreenState extends State<KahwaPriceScreen> {
  static const _priceError = 'Enter a price above 0';

  late Future<void> _prices;

  final _lbpController = TextEditingController();
  final _usdController = TextEditingController();
  final _thankYouController = TextEditingController();

  String? _lbpError;
  String? _usdError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prices = _load();
  }

  @override
  void dispose() {
    _lbpController.dispose();
    _usdController.dispose();
    _thankYouController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prices = await donationRepository.getPrices(authRepository.userId);
    _lbpController.text = prices.lbp.toString();
    _usdController.text = prices.usd.toString();
    _thankYouController.text = prices.thanksMessage ?? '';
  }

  void _reload() => setState(() => _prices = _load());

  Future<void> _save() async {
    final lbp = parseAmount(_lbpController.text) ?? 0;
    final usd = parseAmount(_usdController.text) ?? 0;
    final thanksMessage = _thankYouController.text.trim();

    setState(() {
      _lbpError = lbp < 1 ? _priceError : null;
      _usdError = usd < 1 ? _priceError : null;
    });
    if (_lbpError != null || _usdError != null) return;

    setState(() => _isLoading = true);
    try {
      await donationRepository.savePrices(
        authRepository.userId,
        KahwaPrices(
          lbp: lbp,
          usd: usd,
          thanksMessage: thanksMessage.isEmpty ? null : thanksMessage,
        ),
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
        future: _prices,
        onRetry: _reload,
        builder: (context, _) {
          return PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle('kahwa Price'),
                const SizedBox(height: 40),
                InputText(
                  controller: _lbpController,
                  title: 'Price per kahwa',
                  hint: '1000',
                  prefixText: Currency.lbp.code,
                  errorText: _lbpError,
                  digitsOnly: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                InputText(
                  controller: _usdController,
                  hint: '1',
                  prefixText: Currency.usd.code,
                  errorText: _usdError,
                  digitsOnly: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _thankYouController,
                  title: 'Thank you message',
                  subtitle: 'A message to be shown when someone donates.',
                  hint: 'Thank you for the support! 🎉',
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/core/theme.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/kahwa_prices.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/kahwa_counter.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/user_avatar.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key, required this.creatorId});

  final String creatorId;

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  static const _shortcuts = [1, 3, 5];

  late Future<(AppUser, KahwaPrices)> _data;

  final _kahwasController = TextEditingController(text: '1');
  final _messageController = TextEditingController();

  Currency _currency = Currency.lbp;
  bool _keepPrivate = false;
  bool _isLoading = false;
  bool _isDone = false;

  int get _kahwas => parseAmount(_kahwasController.text) ?? 0;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  @override
  void dispose() {
    _kahwasController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<(AppUser, KahwaPrices)> _load() async {
    final (creator, prices) = await (
      userRepository.getUser(widget.creatorId),
      donationRepository.getPrices(widget.creatorId),
    ).wait;

    if (creator == null) throw StateError('Creator not found');
    return (creator, prices);
  }

  void _reload() => setState(() => _data = _load());

  void _close() {
    context.canPop()
        ? context.pop()
        : context.go(Routes.creator(widget.creatorId));
  }

  Future<void> _donate(AppUser creator, KahwaPrices prices) async {
    final kahwas = _kahwas;
    if (kahwas < 1) {
      showSnack(context, 'Buy at least 1 kahwa');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final price = prices.price(_currency);
      final success = await donationRepository.donate(
        Donation(
          creatorId: creator.id,
          supporterId: authRepository.userId,
          currency: _currency,
          kahwaPrice: price,
          kahwas: kahwas,
          total: price * kahwas,
          message: _messageController.text.trim(),
          keepPrivate: _keepPrivate,
        ),
      );
      if (!mounted) return;

      if (success) {
        setState(() => _isDone = true);
        showSnack(
          context,
          'Congrats! You just bought ${creator.name} '
          '${plural(kahwas, 'kahwa')}',
        );
      } else {
        showSnack(
          context,
          'You do not have enough credit',
          action: SnackBarAction(label: 'Reload', onPressed: _reloadBalance),
        );
      }
    } catch (_) {
      if (mounted) showSnack(context, 'Something went wrong, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reloadBalance() async {
    final url = await balanceRepository.getReloadBalanceUrl().catchError(
      (_) => null,
    );
    if (mounted) await openLink(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: _close)),
        body: AsyncBody(
          future: _data,
          onRetry: _reload,
          builder: (context, data) {
            final (creator, prices) = data;
            return Theme(
              data: appTheme(primary: creator.color.color),
              child: _isDone
                  ? _buildThanks(prices)
                  : _buildForm(context, creator, prices),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThanks(KahwaPrices prices) {
    final message = prices.thanksMessage ?? '';
    return IllustratedMessage(
      asset: 'assets/undraw_super_thank_you.svg',
      message: message.isEmpty ? 'Thank you for your support!' : message,
      action: OutlinedButton(onPressed: _close, child: const Text('Done')),
    );
  }

  Widget _buildForm(BuildContext context, AppUser creator, KahwaPrices prices) {
    final total = prices.price(_currency) * _kahwas;

    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: PageTitle(
                  'Buy ${creator.name.split(' ').first} a kahwa',
                  upperCase: false,
                ),
              ),
              const SizedBox(width: 24),
              UserAvatar(
                name: creator.name,
                image: creator.image,
                color: creator.color.color,
                radius: context.isCompact ? 48 : 56,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Image.asset('assets/cup.png', width: 32),
              const SizedBox(width: 8),
              const Text('×'),
              const SizedBox(width: 8),
              SizedBox(
                width: 88,
                child: InputText(
                  controller: _kahwasController,
                  hint: '0',
                  digitsOnly: true,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Spacer(),
              for (final value in _shortcuts) ...[
                const SizedBox(width: 8),
                KahwaCounter(
                  value: value,
                  selected: _kahwas == value,
                  onTap: () {
                    setState(() => _kahwasController.text = value.toString());
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final currency in Currency.values)
                ChoiceChip(
                  label: Text(currency.code),
                  selected: _currency == currency,
                  onSelected: (_) => setState(() => _currency = currency),
                ),
            ],
          ),
          const SizedBox(height: 24),
          InputText(
            controller: _messageController,
            hint: 'Add a nice message',
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Keep this support private'),
            value: _keepPrivate,
            onChanged: (value) => setState(() => _keepPrivate = value ?? false),
          ),
          const SizedBox(height: 8),
          LoadingButton(
            label: 'Support ${_currency.format(total)}',
            isLoading: _isLoading,
            onPressed: () => _donate(creator, prices),
          ),
        ],
      ),
    );
  }
}

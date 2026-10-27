import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/core/theme.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/kahwa_prices.dart';
import 'package:kahwa/models/pending_kahwa.dart';
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

  /// What the user can spend, shown under the currencies.
  Balance? _balance;

  Currency _currency = Currency.lbp;
  bool _keepPrivate = false;
  bool _isLoading = false;
  bool _isDone = false;

  /// Whether the form was filled in from a kahwa kept while topping up.
  bool _isPending = false;

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
    final (creator, prices, pending, balance) = await (
      userRepository.getUser(widget.creatorId),
      donationRepository.getPrices(widget.creatorId),
      donationRepository.getPending(authRepository.userId),
      balanceRepository.getBalance(authRepository.userId),
    ).wait;

    if (creator == null) throw StateError('Creator not found');
    _balance = balance;

    // Pick up where the user left off before topping up.
    if (pending != null && pending.creatorId == widget.creatorId) {
      _isPending = true;
      _kahwasController.text = '${pending.kahwas}';
      _currency = pending.currency;
      _messageController.text = pending.message;
      _keepPrivate = pending.keepPrivate;
    }
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

    // Everything is read once, here: the form is locked from now on, and a
    // tap on the other currency meanwhile must not mix two prices.
    final currency = _currency;
    final price = prices.price(currency);
    final donation = Donation(
      creatorId: creator.id,
      supporterId: authRepository.userId,
      currency: currency,
      kahwaPrice: price,
      kahwas: kahwas,
      total: price * kahwas,
      message: _messageController.text.trim(),
      keepPrivate: _keepPrivate,
    );

    setState(() => _isLoading = true);
    try {
      // When the balance is short, the top up offer asks instead.
      final balance = _balance?.current(currency);
      if (balance != null && balance >= donation.total) {
        if (!await _confirm(creator, donation)) return;
      }

      final success = await donationRepository.donate(donation);
      if (!mounted) return;

      if (success) {
        if (_isPending) {
          // Bought: nothing to finish later. Failing to clear it is harmless.
          donationRepository.clearPending(authRepository.userId).ignore();
          _isPending = false;
        }
        setState(() => _isDone = true);
        showSnack(
          context,
          'Congrats! You just bought ${creator.name} '
          '${plural(kahwas, 'kahwa')}',
        );
      } else {
        await _offerTopUp(creator, donation);
      }
    } catch (_) {
      if (mounted) showSnack(context, 'Something went wrong, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _confirm(AppUser creator, Donation donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy ${plural(donation.kahwas, 'kahwa')}?'),
        content: Text(
          '${donation.currency.format(donation.total)} goes from your '
          'balance to ${creator.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Buy'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Offers to top up exactly what is missing, and keeps this kahwa so the
  /// user can finish it once the money is in.
  Future<void> _offerTopUp(AppUser creator, Donation donation) async {
    final currency = donation.currency;
    final userId = authRepository.userId;
    final balance = await balanceRepository.getBalance(userId);
    final missing = missingAmount(
      total: donation.total.toInt(),
      balance: balance.current(currency),
    );
    if (!mounted) return;

    final topUp = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not enough credit'),
        content: Text(
          'You need ${currency.format(missing)} more to buy '
          '${creator.name} ${plural(donation.kahwas, 'kahwa')}. Top up that '
          'amount and your kahwa will wait for you here until the top up is '
          'approved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Top up ${currency.format(missing)}'),
          ),
        ],
      ),
    );
    if (topUp != true || !mounted) return;

    await donationRepository.savePending(
      userId,
      PendingKahwa(
        creatorId: creator.id,
        kahwas: donation.kahwas,
        currency: currency,
        message: donation.message,
        keepPrivate: donation.keepPrivate,
      ),
    );
    _isPending = true;
    if (!mounted) return;
    await context.push(Routes.topUpOf(missing, currency));
    // The balance may have changed meanwhile.
    final updated = await balanceRepository.getBalance(userId);
    if (mounted) setState(() => _balance = updated);
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
                  readOnly: _isLoading,
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
                    if (_isLoading) return;
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
                  onSelected: _isLoading
                      ? null
                      : (_) => setState(() => _currency = currency),
                ),
            ],
          ),
          if (_balance case final balance?) ...[
            const SizedBox(height: 8),
            Text(
              'Your balance: ${_currency.format(balance.current(_currency))}',
              style: const TextStyle(color: kGreyColor),
            ),
          ],
          const SizedBox(height: 24),
          InputText(
            controller: _messageController,
            hint: 'Add a nice message',
            readOnly: _isLoading,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Keep this support private'),
            value: _keepPrivate,
            onChanged: _isLoading
                ? null
                : (value) => setState(() => _keepPrivate = value ?? false),
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

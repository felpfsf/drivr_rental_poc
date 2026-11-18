import 'package:booking_mfe/src/data/booking_repository.dart';
import 'package:booking_mfe/src/domain/booking_confirmation.dart';
import 'package:booking_mfe/src/domain/booking_quote.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

enum _BookingStep {
  dates,
  review,
  success,
}

class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    required this.carId,
    required this.onClose,
    required this.repository,
    required this.ensureAuthenticated,
  });

  final String carId;
  final VoidCallback onClose;
  final BookingRepository repository;

  final Future<bool> Function() ensureAuthenticated;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  _BookingStep _step = _BookingStep.dates;

  RentalPeriod? _period;
  BookingQuote? _quote;
  BookingConfirmation? _confirmation;

  bool _isLoadingQuote = false;
  bool _isConfirming = false;

  final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDates() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final lastDate = DateTime(
      today.year + 1,
      today.month,
      today.day,
    );

    final current = _period;

    final initialRange = current != null && !current.start.isBefore(today)
        ? DateTimeRange(
            start: current.start,
            end: current.end,
          )
        : null;

    final selected = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: lastDate,
      initialDateRange: initialRange,
      helpText: 'PERÍODO DO ALUGUEL',
      saveText: 'Aplicar',
    );

    if (!mounted || selected == null) return;

    setState(() {
      _period = RentalPeriod(
        start: selected.start,
        end: selected.end,
      );
      _quote = null;
    });
  }

  Future<void> _openReview() async {
    final period = _period;

    if (period == null || _isLoadingQuote) return;

    setState(() => _isLoadingQuote = true);

    try {
      final quote = await widget.repository.getQuote(
        carId: widget.carId,
        period: period,
      );

      if (!mounted) return;

      setState(() {
        _quote = quote;
        _step = _BookingStep.review;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível calcular o orçamento.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingQuote = false);
      }
    }
  }

  Future<void> _confirmBooking() async {
    if (_isConfirming || _step != _BookingStep.review) {
      return;
    }

    final quote = _quote;
    if (quote == null) return;

    setState(() => _isConfirming = true);

    try {
      // 1. Solicita autenticação quando necessário.
      final authenticated = await widget.ensureAuthenticated();

      if (!mounted || !authenticated) return;

      // 2. Cria a reserva através do repository.
      final confirmation = await widget.repository.createBooking(
        carId: widget.carId,
        period: quote.period,
      );

      if (!mounted) return;

      // 3. Valida o contrato recebido.
      if (confirmation.status != 'confirmed' ||
          confirmation.id.isEmpty ||
          confirmation.carId != widget.carId) {
        throw const FormatException(
          'Resposta de confirmação inválida',
        );
      }

      // 4. Sucesso somente após confirmação da API.
      setState(() {
        _confirmation = confirmation;
        _step = _BookingStep.success;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      final message = switch (error.statusCode) {
        401 => 'Sua sessão não foi aceita pelo servidor.',
        409 => 'Este veículo não está disponível no período.',
        _ => 'Não foi possível confirmar sua reserva.',
      };

      _showError(message);
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Ocorreu um erro ao confirmar a reserva.',
      );
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goBack() {
    switch (_step) {
      case _BookingStep.dates:
      case _BookingStep.success:
        widget.onClose();

      case _BookingStep.review:
        setState(() {
          _step = _BookingStep.dates;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _step == _BookingStep.success;

    return Scaffold(
      backgroundColor: isSuccess ? AppColors.ink : AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: _goBack),
        title: Text(
          switch (_step) {
            _BookingStep.dates => 'Escolher período',
            _BookingStep.review => 'Resumo do aluguel',
            _BookingStep.success => 'Concluído',
          },
        ),
      ),
      body: switch (_step) {
        _BookingStep.dates => _buildDateSelection(),
        _BookingStep.review => _buildReview(),
        _BookingStep.success => _buildSuccess(),
      },
      bottomNavigationBar: switch (_step) {
        _BookingStep.dates => _bottomButton(
          label: _isLoadingQuote ? 'Calculando...' : 'Confirmar período',
          onPressed: _period == null || _isLoadingQuote ? null : _openReview,
        ),
        _BookingStep.review => _bottomButton(
          label: _isConfirming ? 'Validando...' : 'Alugar agora',
          onPressed: _isConfirming ? null : _confirmBooking,
        ),
        _BookingStep.success => null,
      },
    );
  }

  Widget _buildDateSelection() {
    return ListView(
      children: [
        Container(
          color: AppColors.ink,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escolha uma data de início e fim do aluguel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Veículo: ${widget.carId}',
                style: const TextStyle(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _dateLabel(
                      'DE',
                      _period?.start,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _dateLabel(
                      'ATÉ',
                      _period?.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: OutlinedButton.icon(
            key: const Key('select_dates'),
            onPressed: _selectDates,
            icon: const Icon(Icons.calendar_month),
            label: Text(
              _period == null ? 'Selecionar datas' : 'Alterar período',
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateLabel(String title, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          date == null ? '--/--/----' : _formatDate(date),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Divider(color: AppColors.muted),
      ],
    );
  }

  Widget _buildReview() {
    final quote = _quote!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Confira seu aluguel',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Veículo: ${widget.carId}'),
        const SizedBox(height: AppSpacing.lg),
        _summaryRow(
          'Início',
          _formatDate(quote.period.start),
        ),
        _summaryRow(
          'Término',
          _formatDate(quote.period.end),
        ),
        _summaryRow(
          'Diárias',
          '${quote.period.days}',
        ),
        _summaryRow(
          'Valor por diária',
          _currency.format(quote.dailyRate),
        ),
        const Divider(height: 40),
        _summaryRow(
          'TOTAL',
          _currency.format(quote.total),
          highlight: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Reserva de demonstração. '
          'Nenhuma cobrança será realizada.',
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.primary : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    final confirmation = _confirmation!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 72,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Reserva confirmada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Sua reserva foi confirmada '
              'pela API de demonstração.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            SelectableText(
              'Código: ${confirmation.id}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Concluir',
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppButton(
          label: label,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/date_range.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_filter.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';

/// Bottom sheet con filtros de transacciones. Retorna el nuevo filtro si
/// el usuario aplica, `null` si descarta (los drafts se pierden).
Future<TransactionFilter?> showFilterBottomSheet(
  BuildContext context, {
  required TransactionFilter current,
}) {
  return showModalBottomSheet<TransactionFilter>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _FilterBottomSheet(initial: current),
  );
}

class _FilterBottomSheet extends ConsumerStatefulWidget {
  const _FilterBottomSheet({required this.initial});

  final TransactionFilter initial;

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late TransactionType? _type;
  late String? _fundId;
  late DateRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _fundId = widget.initial.fundId;
    _dateRange = widget.initial.dateRange;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _dateRange == null
          ? null
          : DateTimeRange(start: _dateRange!.start, end: _dateRange!.end),
    );
    if (result == null) return;
    setState(() {
      _dateRange = DateRange(start: result.start, end: result.end);
    });
  }

  String _shortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final fundsAsync = ref.watch(fundsNotifierProvider);
    final funds = fundsAsync.valueOrNull ?? const <Fund>[];
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtrar transacciones',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Tipo', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _type == null,
                    onSelected: (_) => setState(() => _type = null),
                  ),
                  ChoiceChip(
                    label: const Text('Suscripciones'),
                    selected: _type == TransactionType.subscription,
                    onSelected: (_) =>
                        setState(() => _type = TransactionType.subscription),
                  ),
                  ChoiceChip(
                    label: const Text('Cancelaciones'),
                    selected: _type == TransactionType.cancellation,
                    onSelected: (_) =>
                        setState(() => _type = TransactionType.cancellation),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Fondo', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String?>(
                initialValue: _fundId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                    child: Text('Todos los fondos'),
                  ),
                  for (final f in funds)
                    DropdownMenuItem<String?>(
                      value: f.id,
                      child: Text(
                        f.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _fundId = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Rango de fechas', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _dateRange == null
                      ? 'Cualquier fecha'
                      : '${_shortDate(_dateRange!.start)} → '
                          '${_shortDate(_dateRange!.end)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_dateRange != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _dateRange = null),
                    child: const Text('Quitar fechas'),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                        context,
                        TransactionFilter(
                          type: _type,
                          fundId: _fundId,
                          dateRange: _dateRange,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandBlack,
                        foregroundColor: AppColors.textOnDark,
                      ),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';

part 'fund.freezed.dart';

@freezed
class Fund with _$Fund {
  const factory Fund({
    required String id,
    required String name,
    required double minimumAmount,
    required FundCategory category,
    @Default('') String description,
  }) = _Fund;
}

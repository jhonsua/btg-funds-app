import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/features/subscriptions/data/datasources/local_subscription_datasource.dart';
import 'package:btg_funds_app/features/subscriptions/data/models/subscription_model.dart';
import 'package:btg_funds_app/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

class _MockDatasource extends Mock implements LocalSubscriptionDatasource {}

void main() {
  late _MockDatasource datasource;
  late SubscriptionRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = SubscriptionRepositoryImpl(datasource);
  });

  final tModel = SubscriptionModel(
    id: 'sub_1',
    fundId: 'f1',
    fundName: 'Fondo X',
    amount: 100000,
    openedAt: DateTime.utc(2026, 5, 12),
    channel: NotificationChannel.email,
  );

  group('SubscriptionRepositoryImpl.getSubscriptions', () {
    test('mapea modelos a entidades y retorna Right', () async {
      when(() => datasource.getSubscriptions())
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getSubscriptions();

      result.fold(
        (_) => fail('Debió ser Right'),
        (subs) {
          expect(subs.length, equals(1));
          expect(subs.first.fundId, equals('f1'));
        },
      );
    });

    test('lista vacía retorna Right([])', () async {
      when(() => datasource.getSubscriptions()).thenAnswer((_) async => []);

      final result = await repository.getSubscriptions();

      result.fold(
        (_) => fail('Debió ser Right'),
        (subs) => expect(subs, isEmpty),
      );
    });

    test('CacheException → Left(CacheFailure)', () async {
      when(() => datasource.getSubscriptions())
          .thenThrow(const CacheException('Corrupto'));

      final result = await repository.getSubscriptions();

      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, equals('Corrupto'));
        },
        (_) => fail('Debió ser Left'),
      );
    });

    test('Exception genérico → Left(CacheFailure)', () async {
      when(() => datasource.getSubscriptions())
          .thenThrow(Exception('inesperado'));

      final result = await repository.getSubscriptions();

      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Debió ser Left'),
      );
    });
  });
}

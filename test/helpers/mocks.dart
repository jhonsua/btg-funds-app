import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import 'package:btg_funds_app/core/storage/atomic_write.dart';
import 'package:btg_funds_app/features/funds/data/datasources/fund_remote_datasource.dart';
import 'package:btg_funds_app/features/funds/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/features/funds/domain/usecases/get_fund_by_id_usecase.dart';
import 'package:btg_funds_app/features/funds/domain/usecases/get_funds_usecase.dart';
import 'package:btg_funds_app/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:btg_funds_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';
import 'package:btg_funds_app/features/user/domain/usecases/get_user_usecase.dart';
import 'package:btg_funds_app/features/user/domain/usecases/reset_demo_usecase.dart';
import 'package:btg_funds_app/features/user/domain/usecases/update_user_usecase.dart';

// User
class MockUserRepository extends Mock implements UserRepository {}

class MockGetUserUseCase extends Mock implements GetUserUseCase {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

class MockResetDemoUseCase extends Mock implements ResetDemoUseCase {}

// Funds
class MockFundRepository extends Mock implements FundRepository {}

class MockFundRemoteDatasource extends Mock implements FundRemoteDatasource {}

class MockGetFundsUseCase extends Mock implements GetFundsUseCase {}

class MockGetFundByIdUseCase extends Mock implements GetFundByIdUseCase {}

// Subscriptions
class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

// Transactions
class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockAddTransactionUseCase extends Mock implements AddTransactionUseCase {}

// Storage / infra
class MockAtomicWrite extends Mock implements AtomicWrite {}

class MockUuid extends Mock implements Uuid {}

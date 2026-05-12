import 'package:mocktail/mocktail.dart';

import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';
import 'package:btg_funds_app/features/user/domain/usecases/get_user_usecase.dart';
import 'package:btg_funds_app/features/user/domain/usecases/reset_demo_usecase.dart';
import 'package:btg_funds_app/features/user/domain/usecases/update_user_usecase.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockGetUserUseCase extends Mock implements GetUserUseCase {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

class MockResetDemoUseCase extends Mock implements ResetDemoUseCase {}

import 'package:edsuite/features/niubiz/domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niubiz/niubiz.dart';
import '../../../features/pos/data/data.dart';
import '../../../features/pos/domain/domain.dart';
import '../../../features/punto_venta/data/repositories/repositories.dart';
import '../../../features/punto_venta/domain/domain.dart';
import '../../core.dart';

List<RepositoryProvider> buildRepositories(Environment env) {
  return [
    //Repositories
    RepositoryProvider<IPosRepository>(create: (context) => PosRepository()),
    RepositoryProvider<IDispenserRepository>(
      create: (context) => DispenserRepository(),
    ),
    RepositoryProvider<IPaymentRepository>(
      create: (context) => PaymentRepository(),
    ),
    RepositoryProvider<IUserRepository>(create: (context) => UserRepository()),
    //DataSources
    RepositoryProvider<NiubizPlatformDataSource>(
      create: (context) => NiubizPlatformDataSourceImpl(),
    ),
    //Services
    RepositoryProvider<KeyValueStorageService>(
      create: (context) => KeyValueStorageServiceImpl(),
    ),

    RepositoryProvider<INiubizRepository>(
      create: (context) =>
          NiubizRepositoryImpl(context.read<NiubizPlatformDataSource>()),
    ),
    //Usecases
    RepositoryProvider<PosUsecases>(
      create: (context) => PosUsecases(
        posRepository: context.read<IPosRepository>(),
        keyValueStorageService: context.read<KeyValueStorageService>(),
      ),
    ),
    RepositoryProvider<DispenserUsecases>(
      create: (context) => DispenserUsecases(
        dispenserRepository: context.read<IDispenserRepository>(),
        keyValueStorageService: context.read<KeyValueStorageService>(),
      ),
    ),
    RepositoryProvider<PaymentUsecases>(
      create: (context) => PaymentUsecases(
        paymentRepository: context.read<IPaymentRepository>(),
        keyValueStorageService: context.read<KeyValueStorageService>(),
      ),
    ),
    RepositoryProvider<NiubizUsecases>(
      create: (context) =>
          NiubizUsecases(niubizRepository: context.read<INiubizRepository>()),
    ),
    RepositoryProvider<UserUsecases>(
      create: (context) => UserUsecases(
        userRepository: context.read<IUserRepository>(),
        keyValueStorageService: context.read<KeyValueStorageService>(),
      ),
    ),
  ];
}

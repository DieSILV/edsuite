import 'package:edsuite/features/niubiz/domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niubiz/niubiz.dart';
import '../../../features/pos/data/data.dart';
import '../../../features/pos/domain/domain.dart';
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
  ];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/pos/data/data.dart';
import '../../../features/pos/domain/domain.dart';
import '../../../features/pos/domain/usecases/dispenser_usecases.dart';
import '../../core.dart';

List<RepositoryProvider> buildRepositories(Environment env) {
  return [
    //Repositories
    RepositoryProvider<IPosRepository>(create: (context) => PosRepository()),
    //Services
    RepositoryProvider<KeyValueStorageService>(
      create: (context) => KeyValueStorageServiceImpl(),
    ),
    RepositoryProvider<IDispenserRepository>(
      create: (context) => DispenserRepository(),
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
  ];
}

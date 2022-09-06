import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voicenotice/Cubits/cubit/all_alarms_cubit.dart';
import 'package:voicenotice/Cubits/cubit/create_alarms_cubit.dart';
import 'package:voicenotice/Cubits/cubit/edit_time_cubit.dart';

class BlocProviders {
  static final List<BlocProvider> providers = [
    BlocProvider(
      create: (_) => AllAlarmsCubit(),
    ),
    BlocProvider(
      create: (_) => EditTimeCubit(),
    ),
    BlocProvider(
      create: (_) => CreateAlarmsCubit(),
    ),
  ];
}

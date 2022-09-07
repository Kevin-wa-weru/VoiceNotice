// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:voicenotice/Cubits/cubit/all_alarms_cubit.dart';
// import 'package:voicenotice/Cubits/cubit/create_alarms_cubit.dart';
// import 'package:voicenotice/Cubits/cubit/edit_time_cubit.dart';
// import 'package:voicenotice/homepage.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key}) : super(key: key);

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => AllAlarmsCubit(),
//         ),
//         BlocProvider(
//           create: (context) => EditTimeCubit(),
//         ),
//         BlocProvider(
//           create: (contex) => CreateAlarmsCubit(),
//         ),
//       ],
//       child: const HomePage(),
//     );
//   }
// }

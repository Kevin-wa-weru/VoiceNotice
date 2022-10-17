import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:voicenotice/Cubits/cubit/contacts_with_app_cubit.dart';
import 'package:voicenotice/Cubits/cubit/received_message_cubit.dart';
import 'package:voicenotice/Cubits/cubit/sent_voices_cubit.dart';

class InstantVoiceNotice extends StatefulWidget {
  const InstantVoiceNotice({Key? key}) : super(key: key);

  @override
  State<InstantVoiceNotice> createState() => _InstantVoiceNoticeState();
}

class _InstantVoiceNoticeState extends State<InstantVoiceNotice>
    with TickerProviderStateMixin {
  late List<dynamic>? allSentMessages = [];
  late List<dynamic>? allreceivedMessages = [];

  @override
  void initState() {
    super.initState();
    context.read<SentVoicesCubit>().getSentMessages();
    context.read<ReceivedMessageCubit>().getReceivedMessages();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isFetching = false;
  void _onRefresh() async {
    setState(() {
      isFetching = true;
    });
    // await Future.delayed(const Duration(milliseconds: 1000));
    await context.read<ContactsWithAppCubit>().getContactsWithApp();
    setState(() {
      isFetching = false;
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // await Future.delayed(const Duration(milliseconds: 1000));
    if (isFetching == true) {
    } else {
      setState(() {});
      _refreshController.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
    return BlocConsumer<SentVoicesCubit, SentVoicesState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
            body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: TabBar(
                  onTap: (index) {
                    print(index);
                    if (index == 1) {
                      context.read<SentVoicesCubit>().getSentMessages();
                    } else {
                      context
                          .read<ReceivedMessageCubit>()
                          .getReceivedMessages();
                    }
                  },
                  labelColor: Colors.black,
                  labelStyle: const TextStyle(
                    color: Color(0xCC385A64),
                    fontFamily: 'Skranji',
                    fontSize: 18,
                  ),
                  labelPadding: const EdgeInsets.only(left: 20, right: 50),
                  isScrollable: true,
                  unselectedLabelColor: Colors.grey,
                  controller: tabController,
                  indicator: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xCC385A64), width: 5)),
                  ),
                  tabs: const [
                    Tab(text: 'Sent '),
                    Tab(text: 'Received '),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      BlocBuilder<SentVoicesCubit, SentVoicesState>(
                        builder: (context, state) {
                          return state.when(
                              initial: () => Column(
                                    children: const [
                                      SizedBox(height: 100),
                                      Center(
                                          child: CircularProgressIndicator(
                                        color: Color(0xCC385A64),
                                        strokeWidth: 5,
                                      )),
                                    ],
                                  ),
                              loading: () => Column(
                                    children: const [
                                      SizedBox(height: 100),
                                      Center(
                                          child: CircularProgressIndicator(
                                        color: Color(0xCC385A64),
                                        strokeWidth: 5,
                                      )),
                                    ],
                                  ),
                              loaded: (List<dynamic> allmessages) {
                                allSentMessages = allmessages;

                                if (allSentMessages!.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 250.25,
                                          width: 200.5,
                                          child: Image.asset(
                                            "assets/images/empty.gif",
                                            height: 125.0,
                                            width: 125.0,
                                          ),
                                        ),
                                        const Text(
                                            'You havent sent a notice yet',
                                            style: TextStyle(
                                              color: Color(0xCC385A64),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text(
                                            'Tap the button below to send',
                                            style: TextStyle(
                                              color: Color(0xFF7689D6),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Column(
                                      children: allmessages
                                          .map((message) => SingleSentMessage(
                                                singleMessage: message,
                                              ))
                                          .toList());
                                }
                              },
                              error: (String message) => Center(
                                    child: Text(message),
                                  ));
                        },
                      ),
                      BlocBuilder<ReceivedMessageCubit, ReceivedMessageState>(
                        builder: (context, state) {
                          return state.when(
                              initial: () => Column(
                                    children: const [
                                      SizedBox(height: 100),
                                      Center(
                                          child: CircularProgressIndicator(
                                        color: Color(0xCC385A64),
                                        strokeWidth: 5,
                                      )),
                                    ],
                                  ),
                              loading: () => Column(
                                    children: const [
                                      SizedBox(height: 100),
                                      Center(
                                          child: CircularProgressIndicator(
                                        color: Color(0xCC385A64),
                                        strokeWidth: 5,
                                      )),
                                    ],
                                  ),
                              loaded: (List<dynamic> allmessages) {
                                allreceivedMessages = allmessages;

                                if (allreceivedMessages!.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 250.25,
                                          width: 200.5,
                                          child: Image.asset(
                                            "assets/images/empty.gif",
                                            height: 125.0,
                                            width: 125.0,
                                          ),
                                        ),
                                        const Text('It is empty here',
                                            style: TextStyle(
                                              color: Color(0xCC385A64),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Column(
                                      children: allmessages
                                          .map((message) =>
                                              SingleReceivedMessage(
                                                singleMessage: message,
                                              ))
                                          .toList());
                                }
                              },
                              error: (String message) => Center(
                                    child: Text(message),
                                  ));
                        },
                      ),
                    ],
                  ))
            ],
          ),
        ));
      },
    );
  }
}

class SingleSentMessage extends StatefulWidget {
  const SingleSentMessage({
    Key? key,
    required this.singleMessage,
  }) : super(key: key);
  final Map<String, dynamic> singleMessage;

  @override
  State<SingleSentMessage> createState() => _SingleSentMessageState();
}

class _SingleSentMessageState extends State<SingleSentMessage> {
  bool isPlaying = false;
  final player = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 20.0),
      child: Dismissible(
        background: Container(
          alignment: Alignment.centerRight,
          color: Colors.transparent,
          child: const Icon(
            Icons.delete,
            size: 30.0,
            color: Colors.black54,
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) async {
          var collection = FirebaseFirestore.instance.collection('messages');
          var snapshot = await collection
              .where('audioCompleteUrl',
                  isEqualTo: widget.singleMessage['audioCompleteUrl'])
              .get();
          await snapshot.docs.first.reference.delete();
        },
        key: Key(widget.singleMessage['DateTime'].toString()),
        child: ListTile(
          leading: Transform.translate(
            offset: const Offset(-10.0, 0.0),
            child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.all(Radius.circular(170)),
                  border: Border.all(
                    color: Colors.black12,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(widget.singleMessage['createdForUserName'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Skranji',
                        fontSize: 18,
                      )),
                )),
          ),
          title: Row(
            children: [
              Text(widget.singleMessage['createdForUserName'],
                  style: const TextStyle(
                    color: Color(0xCC385A64),
                    fontFamily: 'Skranji',
                    fontSize: 20,
                  )),
              const SizedBox(width: 10),
              Transform.translate(
                offset: const Offset(0.0, 4.0),
                child: Text(
                    '${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).day}/${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).month}/${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).year}',
                    style: const TextStyle(
                      color: Colors.black12,
                      fontFamily: 'Skranji',
                      fontSize: 10,
                    )),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
                '${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).hour} : ${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).minute}  ${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).hour > 12 ? 'PM' : 'AM'}',
                style: const TextStyle(
                  color: Color(0xCC385A64),
                  fontFamily: 'Skranji',
                  fontSize: 18,
                )),
          ),
          trailing: Transform.translate(
            offset: const Offset(-60.0, 8.0),
            child: Container(
              height: 50.00,
              width: 50.5,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(150)),
                border: Border.all(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 6.0, right: 4.0, top: 4.0, bottom: 4.0),
                child: Center(
                  child: SizedBox(
                    height: 25.00,
                    width: 25.5,
                    child: isPlaying == true
                        ? InkWell(
                            onTap: () async {
                              setState(() {
                                isPlaying = false;
                                player.pause();
                              });
                            },
                            child: SvgPicture.asset('assets/icons/pause.svg',
                                color: Colors.green, fit: BoxFit.fitHeight),
                          )
                        : InkWell(
                            onTap: () async {
                              print('What is haaapening??');
                              setState(() {
                                isPlaying = true;
                              });

                              await player.play(UrlSource(
                                  widget.singleMessage['audioCompleteUrl']));

                              var duration = await player.getDuration();

                              print(duration);
                              Timer(duration!, () {
                                setState(() {
                                  isPlaying = false;
                                });
                              });
                            },
                            child: SvgPicture.asset('assets/icons/play.svg',
                                color: Colors.green, fit: BoxFit.fitHeight),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SingleReceivedMessage extends StatefulWidget {
  const SingleReceivedMessage({
    Key? key,
    required this.singleMessage,
  }) : super(key: key);
  final Map<String, dynamic> singleMessage;

  @override
  State<SingleReceivedMessage> createState() => _SingleReceivedMessageState();
}

class _SingleReceivedMessageState extends State<SingleReceivedMessage> {
  bool isPlaying = false;
  final player = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 20.0),
      child: Dismissible(
        background: Container(
          alignment: Alignment.centerRight,
          color: Colors.transparent,
          child: const Icon(
            Icons.delete,
            size: 30.0,
            color: Colors.black54,
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) async {
          var collection = FirebaseFirestore.instance.collection('messages');
          var snapshot = await collection
              .where('audioCompleteUrl',
                  isEqualTo: widget.singleMessage['audioCompleteUrl'])
              .get();
          await snapshot.docs.first.reference.delete();
        },
        key: Key(widget.singleMessage['DateTime'].toString()),
        child: ListTile(
          leading: Transform.translate(
            offset: const Offset(-10.0, 0.0),
            child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.all(Radius.circular(170)),
                  border: Border.all(
                    color: Colors.black12,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(widget.singleMessage['createdByUserName'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Skranji',
                        fontSize: 18,
                      )),
                )),
          ),
          title: Row(
            children: [
              Text(widget.singleMessage['createdByUserName'],
                  style: const TextStyle(
                    color: Color(0xCC385A64),
                    fontFamily: 'Skranji',
                    fontSize: 20,
                  )),
              const SizedBox(width: 10),
              Transform.translate(
                offset: const Offset(0.0, 4.0),
                child: Text(
                    '${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).day}/${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).month}/${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).year}',
                    style: const TextStyle(
                      color: Colors.black12,
                      fontFamily: 'Skranji',
                      fontSize: 10,
                    )),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
                '${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).hour} : ${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).minute}  ${DateTime.parse(widget.singleMessage['DateTime'].toDate().toString()).hour > 12 ? 'PM' : 'AM'}',
                style: const TextStyle(
                  color: Color(0xCC385A64),
                  fontFamily: 'Skranji',
                  fontSize: 18,
                )),
          ),
          trailing: Transform.translate(
            offset: const Offset(-60.0, 8.0),
            child: Container(
              height: 50.00,
              width: 50.5,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(150)),
                border: Border.all(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 6.0, right: 4.0, top: 4.0, bottom: 4.0),
                child: Center(
                  child: SizedBox(
                    height: 25.00,
                    width: 25.5,
                    child: isPlaying == true
                        ? InkWell(
                            onTap: () async {
                              setState(() {
                                player.pause();
                                isPlaying = false;
                              });
                            },
                            child: SvgPicture.asset('assets/icons/pause.svg',
                                color: Colors.green, fit: BoxFit.fitHeight),
                          )
                        : InkWell(
                            onTap: () async {
                              print('What is haaapening??');
                              setState(() {
                                isPlaying = true;
                              });

                              await player.play(UrlSource(
                                  widget.singleMessage['audioCompleteUrl']));

                              var duration = await player.getDuration();

                              print(duration);
                              Timer(duration!, () {
                                setState(() {
                                  isPlaying = false;
                                });
                              });
                            },
                            child: SvgPicture.asset('assets/icons/play.svg',
                                color: Colors.green, fit: BoxFit.fitHeight),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

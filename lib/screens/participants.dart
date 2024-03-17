import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twyshe/classes/converation.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/chat.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';
import 'package:twyshe/utils/assist.dart';

class ParticipantsPage extends StatefulWidget {
  final String peer;

  const ParticipantsPage({super.key, required this.peer});

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  List<TwysheUser> items = [];

  bool loading = true;
  bool succeeded = false;

  late final TwysheUser profile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      loading = true;
    });

    profile = await Assist.getUserProfile();

    TwysheTaskResult rs = await TwysheAPI.fetchPeerParticipants(widget.peer);

    if (rs.succeeded) {
      setState(() {
        items = rs.items as List<TwysheUser>;
        succeeded = true;
        loading = false;
      });
    } else {
      setState(() {
        items = [];
        succeeded = false;
        loading = false;
      });
    }
  }

  ///Adds a new discussion to firestore
  void _startConversation(TwysheUser other) async {
    String? conversationId = Assist.getCoversationId(profile.phone, other.phone);

    if (conversationId == null) {
      //same phone number
      Assist.showSnackBar(context, 'Sorry! But you cannot chat with yourself!');
    } else {
      TwysheConversation conversation = TwysheConversation(
          conversationId,
          profile.phone,
          profile.nickname,
          other.phone,
          Timestamp.now(),
          1,
          0,
          other.color,
          other.nickname,);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    }
  }

  Widget _getView() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else {
      if (!succeeded) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'An error has occurred!',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                child: const Text('Try again...',
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _loadData();
                },
              ),
            ],
          ),
        );
      } else {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: ListTile(
                title: Text(items[index].nickname,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),
                subtitle: Text(items[index].phone),
                onTap: () {
                  _startConversation(items[index]);
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
      ),
      body: _getView(),
      backgroundColor: Colors.purple,
    );
  }
}

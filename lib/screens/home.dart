import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twyshe/classes/converation.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/chat.dart';
import 'package:twyshe/screens/discussions.dart';
import 'package:twyshe/screens/profile.dart';
import 'package:twyshe/screens/resources.dart';
import 'package:twyshe/utils/assist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final DiscussionsPage _discussionPage =
      const DiscussionsPage(title: 'Discussions');

  final ResourcePage _resourcePage = const ResourcePage(title: 'Resources');

  String nickname = '';
  String phone = '';
  String pn = '';

  @override
  void initState() {
    super.initState();
    _setUser();
  }

  void _setUser() async {
    TwysheUser profile = await Assist.getUserProfile();

    setState(() {
      nickname = profile.nickname;
      phone = profile.phone;
      pn = profile.pnPhone;
    });
  }

  ///Adds a new discussion to firestore
  void _startConversation(String conversationId) async {
    FirebaseFirestore.instance
        .collection(Assist.firestireConversationsKey)
        .doc(conversationId)
        .set(<String, dynamic>{
      'user': phone,
      'nickname': nickname,
      'pn': pn,
      'posted': Timestamp.now(),
      'status': 1,
      'posts': 0,
    }).then((value) {
      Assist.log(
          'The conversation \'$conversationId\' has been successfully added!');

      TwysheConversation conversation = TwysheConversation(
          conversationId, phone, nickname, pn, Timestamp.now(), 1, 0);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );

      
    }).onError((error, stackTrace) {
      Assist.showSnackBar(
          context, 'Unable to start the chat. Please try again');

      Assist.log('Unable to add the conversation: $error');
    });
  }

  ListTile _tile(BuildContext context, int index, String title, String subtitle,
      IconData icon,
      {Color mycolor = Colors.purple}) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          )),
      subtitle: Text(subtitle),
      leading: Icon(
        icon,
        color: mycolor,
        size: 48,
      ),
      onTap: () {
        Assist.log('The item has been tapped at $index');

        if (index == 1) {
          String? conversationId = Assist.getCoversationId(phone, pn);

          if (conversationId == null) {
            //same phone number
            Assist.showSnackBar(
                context, 'Sorry! But you cannot chat with yourself!');
          } else {
            //start conversation
            Assist.log(
                'Starting conversation for user $phone and peer navigator $pn and $conversationId computed id');

            _startConversation(conversationId);
          }
        } else if (index >= 2 && index <= 4) {
          _showUpdateProfile();
        } else if (index == 7) {
          Assist.removeUser();
        }
      },
    );
  }

  Future<void> _showUpdateProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ProfilePage(
                title: 'Update Profile',
              )),
    );

    _setUser();
  }

  ListView _getHomeContent(BuildContext context) {
    return ListView(
      children: [
        _tile(context, 1, 'My Peer Navigator - $pn',
            'Chat with your peer navigator', Icons.personal_injury),
        const Divider(),
        _tile(context, 2, nickname, 'Your nickname. Tap to change', Icons.face),
        _tile(context, 3, 'My Color', 'Your color. Tap to change',
            Icons.color_lens,
            mycolor: Colors.orange),
        _tile(context, 4, 'PIN', 'Your PIN secures your app. Tap to change',
            Icons.key_rounded),
        _tile(context, 5, phone,
            'Your phone number. Your number cannot be changed', Icons.phone),
        const Divider(),
        _tile(context, 6, 'Help', 'View help information', Icons.help),
        _tile(context, 7, 'About', 'See version information about this app',
            Icons.info),
      ],
    );
  }

  Widget _getView(BuildContext context, index) {
    if (index == 0) {
      return _getHomeContent(context);
    } else if (index == 1) {
      return _discussionPage;
    } else {
      return _resourcePage;
    }
  }

  void _onBottomNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _getView(context, _selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Discussions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Resources',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onBottomNavigationItemTapped,
      ),
    );
  }
}

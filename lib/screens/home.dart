import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twyshe/classes/converation.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/chat.dart';
import 'package:twyshe/screens/conversations.dart';
import 'package:twyshe/screens/discussions.dart';
import 'package:twyshe/screens/facilities.dart';
import 'package:twyshe/screens/facility_map.dart';
import 'package:twyshe/screens/register.dart';
import 'package:twyshe/screens/resources.dart';
import 'package:twyshe/screens/settings.dart';
import 'package:twyshe/utils/assist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title, required this.user});

  final String title;
  final String user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final DiscussionsPage _discussionPage =
      const DiscussionsPage(title: 'Discussions');

  final ResourcesPage _resourcePage = const ResourcesPage(title: 'Resources');

  late final ConversationsPage _conversationsPage;

  String nickname = '';
  String phone = '';
  String color = '';

  String pnPhone = '';
  String pnColor = Assist.defaultColor;
  String pnName = Assist.defaultName;

  @override
  void initState() {
    super.initState();
    _setUser();

    _conversationsPage = ConversationsPage(
      title: 'Conversations',
      user: widget.user,
    );
  }

  void _setUser() async {
    TwysheUser profile = await Assist.getUserProfile();

    setState(() {
      nickname = profile.nickname;
      phone = profile.phone;
      color = profile.color;
      pnPhone = profile.pnPhone;
    });
  }

  ///Adds a new discussion to firestore
  void _startConversation(
      String conversationId, bool isUser, bool startConversation) async {
    TwysheConversation conversation = TwysheConversation(conversationId, phone,
        nickname, pnPhone, Timestamp.now(), 1, 0, pnColor, pnName);

    if (startConversation) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    }
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
          String? conversationId = Assist.getCoversationId(phone, pnPhone);

          if (conversationId == null) {
            //same phone number
            Assist.showSnackBar(
                context, 'Sorry! But you cannot chat with yourself!');
          } else {
            //start conversation

            Assist.log(
                'Starting conversation for user  peer navigator $pnPhone and $phone and $conversationId computed id');

            _startConversation(conversationId, false, false);

            //start conversation
            Assist.log(
                'Starting conversation for user $phone and peer navigator $pnPhone and $conversationId computed id');

            _startConversation(conversationId, true, true);
          }
        } else if (index >= 2 && index <= 4) {
          _showUpdateProfile();
        } else if (index == 6) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FacilitiesPage(title: 'Facilities'),
            ),
          );
        } else if (index == 7) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FacilityMap(),
            ),
          );
        } else if (index == 8) {
          Assist.removeUser();
          FirebaseAuth.instance.signOut();

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterPage(title: 'Register'),
              ),
              (route) => false);
        }
      },
    );
  }

  Future<void> _showUpdateProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const SettingsPage(
                title: 'Update Profile',
              )),
    );

    _setUser();
  }

  ListView _getHomeContent(BuildContext context) {
    return ListView(
      children: [
        _tile(context, 1, 'My Peer Navigator - $pnPhone',
            'Chat with your peer navigator', Icons.personal_injury),
        const Divider(),
        _tile(context, 2, nickname, 'Your nickname. Tap to change', Icons.face),
        _tile(context, 3, 'My Color', 'Your color. Tap to change',
            Icons.color_lens,
            mycolor: color == '' ? Colors.purple : Assist.getHexColor(color)),
        _tile(context, 4, 'PIN', 'Your PIN secures your app. Tap to change',
            Icons.key_rounded),
        _tile(context, 5, phone,
            'Your phone number. Your number cannot be changed', Icons.phone),
        const Divider(),
        _tile(context, 6, 'Facilities',
            'View facilities providing SRH services', Icons.local_hospital),
        const Divider(),
        _tile(context, 7, 'Map', 'View a map for facilities', Icons.map),
        const Divider(),
        _tile(context, 8, 'Logout', 'Remove your account from this device',
            Icons.remove_circle_outline_outlined),
        const Divider(),
        _tile(context, 9, 'Help', 'View help information', Icons.help),
        _tile(context, 10, 'About', 'See version information about this app',
            Icons.info),
      ],
    );
  }

  Widget _getView(BuildContext context, index) {
    if (index == 0) {
      return _getHomeContent(context);
    } else if (index == 1) {
      return _discussionPage;
    } else if (index == 2) {
      return _conversationsPage;
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
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.messenger_outline_sharp),
            label: 'Chats',
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twyshe/classes/converation.dart';
import 'package:twyshe/classes/discussion.dart';
import 'package:twyshe/classes/menu.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/about.dart';
import 'package:twyshe/screens/chat.dart';
import 'package:twyshe/screens/conversations.dart';
import 'package:twyshe/screens/discussion.dart';
import 'package:twyshe/screens/discussions.dart';
import 'package:twyshe/screens/facilities.dart';
import 'package:twyshe/screens/facility_map.dart';
import 'package:twyshe/screens/help.dart';
import 'package:twyshe/screens/participants.dart';
import 'package:twyshe/screens/peers.dart';
import 'package:twyshe/screens/register.dart';
import 'package:twyshe/screens/resources.dart';
import 'package:twyshe/screens/settings.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';
import 'package:twyshe/utils/assist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title, required this.user});

  final String title;
  final String user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TwysheMenu> items = [];
  List<BottomNavigationBarItem> tabs = [];

  int _selectedIndex = 0;

  final ResourcesPage _resourcePage = const ResourcesPage(title: 'Resources');
  final FacilitiesPage _facilitiesPage =
      const FacilitiesPage(title: 'Facilities');

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
    _setUserData();

    _conversationsPage = ConversationsPage(
      title: 'Conversations',
      user: widget.user,
    );
  }

  void _setUserData() async {
    TwysheUser profile = await Assist.getUserProfile();

    setState(() {
      nickname = profile.nickname;
      phone = profile.phone;
      color = profile.color;
    });

    var userMenu = [
      TwysheMenu(
          name: 'nickname',
          description: 'Your nickname. Tap to change',
          title: 'Nickname',
          icon: Icons.face),
      TwysheMenu(
          name: 'color',
          description: 'Your color. Tap to change',
          title: 'My Color',
          color: color == '' ? Colors.purple : Assist.getHexColor(color),
          icon: Icons.color_lens),
      TwysheMenu(
          name: 'pin',
          description: 'Your PIN secures your app. Tap to change',
          title: 'PIN',
          icon: Icons.key_rounded),
      TwysheMenu(
          name: 'phone',
          description: 'Your phone number. Your number cannot be changed',
          title: 'Phone',
          icon: Icons.phone),
      TwysheMenu(
          name: 'facilities',
          description: 'View facilities providing SRH services',
          title: 'Facilities',
          icon: Icons.local_hospital),
      TwysheMenu(
          name: 'map',
          description: 'View a map for facilities',
          title: 'Map',
          icon: Icons.map),
      TwysheMenu(
          name: 'help',
          description: 'View help information',
          title: 'Help',
          icon: Icons.help),
      TwysheMenu(
          name: 'about',
          description: 'See version information about this app',
          title: 'About',
          icon: Icons.help),
      TwysheMenu(
          name: 'logout',
          description: 'Remove your account from this device',
          title: 'Logout',
          icon: Icons.remove_circle_outline_outlined)
    ];

    setState(() {
      items.addAll(userMenu);
    });

    _performHandshake(profile.phone);

    Assist.updateUserStatus(twysheUser: profile, typing: false);
  }

  void _performHandshake(String currentPhone) async {
    TwysheTaskResult rs = await TwysheAPI.performHandshake(currentPhone);

    if (rs.succeeded) {
      TwysheUser current = rs.data as TwysheUser;

      if (current.status == Assist.userParticipant) {
        _loadPeerNavigator();
      } else if (current.status == Assist.userPeer) {
        //ensure the participants menu is loaded only once
        if (items[0].name != 'participants') {
          items.insert(
            0,
            TwysheMenu(
                name: 'discussions',
                description: 'View and start discussion chats',
                title: 'Discussions',
                icon: Icons.people_alt),
          );

          items.insert(
            0,
            TwysheMenu(
                name: 'conversations',
                description: 'View your chats with peers and participants',
                title: 'Conversations',
                icon: Icons.messenger_outline_sharp),
          );
          items.insert(
            0,
            TwysheMenu(
                name: 'peers',
                description: 'View and chat with other peer navigators',
                title: 'Peer Navigators',
                icon: Icons.personal_injury_rounded),
          );
          items.insert(
            0,
            TwysheMenu(
                name: 'peer-discussion',
                description: 'Discussion for all peer navigators',
                title: 'Peer Navigator Chat',
                icon: Icons.comment_outlined),
          );
          items.insert(
            0,
            TwysheMenu(
                name: 'participants',
                description: 'View your participants',
                title: 'Participants',
                icon: Icons.person_outline_rounded),
          );

          setState(() {
            items = items;
          });
        }
      }

      Assist.saveProfile(
          current.pin, current.nickname, current.color, current.status);
    }
  }

  void _loadPeerNavigator() async {
    //ensure the peer menu is only loaded once
    if (items[0].name != 'peer') {
      TwysheTaskResult rs = await TwysheAPI.fetchParticipantPeer(phone);

      if (rs.succeeded) {
        TwysheUser peer = rs.data as TwysheUser;
        items.insert(
          0,
          TwysheMenu(
              name: 'peer',
              description: 'Chat with your Peer Navigator',
              title: 'My Peer Navigator - ${peer.nickname}',
              icon: Icons.supervised_user_circle,
              tag: peer),
        );

        setState(() {
          items = items;
          pnPhone = peer.phone;
          pnName = peer.nickname;
        });
      }
    }
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

  void _startPeerDiscussion() {
    TwysheDiscussion discussion = TwysheDiscussion(
        Assist.firestorePeerNavigatorDiscussionKey,
        "Peer Navigators",
        "Discussion for all PN's",
        phone,
        nickname,
        color,
        0,
        Timestamp.now(),
        '');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiscussionPage(discussion: discussion),
      ),
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

    _setUserData();
  }

  String _getTitle(String title) {
    if (title == 'Nickname') {
      return nickname;
    } else if (title == 'Phone') {
      return phone;
    } else {
      return title;
    }
  }

  ListView _getHomeContent(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(_getTitle(items[index].title),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              )),
          subtitle: Text(items[index].description),
          leading: Icon(
            items[index].icon,
            color: items[index].color ?? Colors.purple,
            size: 48,
          ),
          onTap: () {
            Assist.log('You clicked ${items[index].name}');

            if (items[index].name == 'peer') {
              String? conversationId = Assist.getCoversationId(phone, pnPhone);

              if (conversationId == null) {
                //same phone number
                Assist.showSnackBar(
                    context, 'Sorry! But you cannot chat with yourself!');
              } else {
                //start conversation
                Assist.log(
                    'Starting conversation for user $phone and peer navigator $pnPhone and $conversationId computed id');

                _startConversation(conversationId, true, true);
              }
            } else if (items[index].name == 'peers') {
              //view list of peers
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PeersPage(
                    twysheUser: TwysheUser(
                        color: color,
                        nickname: nickname,
                        phone: phone,
                        pin: '',
                        status: Assist.messageStateActive),
                  ),
                ),
              );
            } else if (items[index].name == 'peer-discussion') {
              //start peer navigator chat
              _startPeerDiscussion();
            } else if (items[index].name == 'nickname' ||
                items[index].name == 'color' ||
                items[index].name == 'pin') {
              _showUpdateProfile();
            } else if (items[index].name == 'facilities') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const FacilitiesPage(title: 'Facilities'),
                ),
              );
            } else if (items[index].name == 'participants') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParticipantsPage(peer: phone),
                ),
              );
            } else if (items[index].name == 'map') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FacilityMap(),
                ),
              );
            } else if (items[index].name == 'conversations') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  ConversationsPage(title: 'Conversations', user: phone,),
                ),
              );
            }else if (items[index].name == 'discussions') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiscussionsPage(title: 'Discussions'),
                ),
              );
            }else if (items[index].name == 'help') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpPage(),
                ),
              );
            } else if (items[index].name == 'about') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            } else if (items[index].name == 'logout') {
              _showConfirmAccountRemovalDialog(context);
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  void _showConfirmAccountRemovalDialog(BuildContext context) {
    // set up the button
    Widget removeButton = TextButton(
      child: const Text("Remove"),
      onPressed: () {
        Navigator.pop(context);
        Assist.removeUser();
        FirebaseAuth.instance.signOut();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterPage(title: 'Register'),
            ),
            (route) => false);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Remove Account"),
      content: const Text(
          "Are you sure you want to remove your account from this device?"),
      actions: [cancelButton, removeButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _getView(BuildContext context, index) {
    if (index == 0) {
      return _getHomeContent(context);
    } else if (index == 1) {
      return _facilitiesPage;
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
      body: _getView(context, _selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_outlined),
            label: 'Facilities',
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

import 'package:flutter/material.dart';
import 'package:kitchen/screens/discussions.dart';
import 'package:kitchen/screens/register.dart';
import 'package:kitchen/screens/resources.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  int _selectedIndex = 0;

  final DiscussionPage _discussionPage =
      const DiscussionPage(title: 'Discussions');
  final ResourcePage _resourcePage = const ResourcePage(title: 'Resources');

  static ListTile _tile(
      BuildContext context, String title, String subtitle, IconData icon,
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const RegisterPage(title: 'Register'),
          ),
        );
      },
    );
  }

  static ListView _getHomeContent(BuildContext context) {
    return ListView(
      children: [
        _tile(context, 'My Peer Navigator', 'Chat with your peer navigator',
            Icons.personal_injury),
        const Divider(),
        _tile(context, 'Butterfly', 'Your nickname. Tap to change', Icons.face),
        _tile(
            context, 'My Color', 'Your color. Tap to change', Icons.color_lens,
            mycolor: Colors.orange),
        _tile(context, 'PIN', 'Your PIN secures your app. Tap to change',
            Icons.key_rounded),
        const Divider(),
        _tile(context, 'Help', 'View help information', Icons.help),
        _tile(context, 'About', 'See version information about this app',
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

  void _onItemTapped(int index) {
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
        onTap: _onItemTapped,
      ),
    );
  }
}

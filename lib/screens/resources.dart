import 'package:flutter/material.dart';
import 'package:twyshe/classes/resource.dart';
import 'package:twyshe/screens/resource.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';

class ResourcesPage extends StatefulWidget {
  final String title;

  const ResourcesPage({super.key, required this.title});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  List<TwysheResource> items = [];

  bool loading = true;
  bool succeeded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      loading = true;
    });

    TwysheTaskResult rs = await TwysheAPI.fetchTwysheResources();

    if (rs.succeeded) {
      setState(() {
        items = rs.items as List<TwysheResource>;
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
                title: Text(items[index].resourceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),
                subtitle: Text(items[index].resourceDescription),
                leading: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      NetworkImage(items[index].resourceThumbnailUrl),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResourcePage(resource: items[index]),
                    ),
                  );
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
      body: _getView(),
      backgroundColor: Colors.purple,
    );
  }
}

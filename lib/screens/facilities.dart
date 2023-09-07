import 'package:flutter/material.dart';
import 'package:twyshe/classes/facility.dart';
import 'package:twyshe/screens/facility.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';

class FacilitiesPage extends StatefulWidget {
  final String title;

  const FacilitiesPage({super.key, required this.title});

  @override
  State<FacilitiesPage> createState() => _FacilitiesPageState();
}

class _FacilitiesPageState extends State<FacilitiesPage> {
  List<TwysheFacility> items = [];

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

    TwysheTaskResult rs = await TwysheAPI.fetchTwysheFacilities();

    if (rs.succeeded) {
      setState(() {
        items = rs.items as List<TwysheFacility>;
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
                title: Text(items[index].facilityName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),
                subtitle: Text(items[index].facilityAddress),
                leading: Image(
                  width: 80,
                  image: NetworkImage(items[index].facilityThumbnailUrl),
                ),
                onTap: () {
                     Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FacilityPage(facility: items[index]),
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getView(),
      backgroundColor: Colors.purple,
    );
  }
}

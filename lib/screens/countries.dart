import 'package:flutter/material.dart';
import 'package:twyshe/classes/country.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';

class CountryPage extends StatefulWidget {
  final String title;

  const CountryPage({super.key, required this.title});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  List<TwysheCountry> items = [];

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

    //load local first
    TwysheTaskResult rs = await TwysheAPI.fetchLocalTwysheCountries();
    bool loadedLocally = false;

    if (rs.succeeded) {
      setState(() {
        items = rs.items as List<TwysheCountry>;
        succeeded = true;
        loading = false;
      });

      loadedLocally = true;
    }

    //finally load online
    rs = await TwysheAPI.fetchTwysheCountries();
    if (!mounted) {
      return;
    }

    if (rs.succeeded) {
      setState(() {
        items = rs.items as List<TwysheCountry>;
        succeeded = true;
        loading = false;
      });
    } else {
      if (!loadedLocally) {
        setState(() {
          items = [];
          succeeded = false;
          loading = false;
        });
      }
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
                title: Text(items[index].countryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),
                subtitle: Text(items[index].countryCode),
                onTap: () {
                  Navigator.pop(context, items[index]);
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

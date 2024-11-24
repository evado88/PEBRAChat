import 'package:flutter/material.dart';
import 'package:twyshe/classes/resource.dart';
import 'package:twyshe/utils/assist.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';

class ResourcePage extends StatefulWidget {
  final TwysheResource resource;

  const ResourcePage({super.key, required this.resource});

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  ListTile _tile(
      BuildContext context, int index, String title, String subtitle) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          )),
      subtitle: Text(subtitle),
      onTap: () {
        Assist.log('The resource item has been tapped at $index');

        if (index == 3) {
          Assist.openWebLink(context, widget.resource.resourceUrl);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource.resourceName),
      ),
      body: ListView(children: [
        _tile(
          context,
          1,
          widget.resource.resourceName,
          'Name',
        ),
        const Divider(),
        _tile(
          context,
          2,
          widget.resource.resourceDescription,
          'Description',
        ),
        const Divider(),
        _tile(
          context,
          3,
          widget.resource.resourceUrl,
          'URL',
        ),
        const Divider(),
      ]),
    );
  }
}

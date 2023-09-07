import 'package:flutter/material.dart';
import 'package:twyshe/classes/facility.dart';
import 'package:twyshe/utils/assist.dart';

class FacilityPage extends StatefulWidget {
  final TwysheFacility facility;

  const FacilityPage({super.key, required this.facility});

  @override
  State<FacilityPage> createState() => _FacilityPageState();
}

class _FacilityPageState extends State<FacilityPage> {
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
        Assist.log('The facility item has been tapped at $index');

        if (index == 5) {

          Assist.openEmailLink(context, widget.facility.facilityEmail);

        } else if (index == 6) {

          Assist.openWebLink(context, widget.facility.facilityWebsite);

        } else if (index == 7) {

          Assist.openTelephoneLink(context, widget.facility.facilityPhone);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.facility.facilityName),
      ),
      body: ListView(children: [
        _tile(
          context,
          1,
          widget.facility.facilityName,
          'Name',
        ),
        _tile(
          context,
          2,
          widget.facility.facilityAddress,
          'Address',
        ),
        const Divider(),
        _tile(
          context,
          3,
          widget.facility.facilityTollfree,
          'Toll-free',
        ),
        const Divider(),
        _tile(
          context,
          4,
          widget.facility.facilityWhatsapp,
          'WhatsApp',
        ),
        const Divider(),
        _tile(
          context,
          5,
          widget.facility.facilityEmail,
          'Email',
        ),
        const Divider(),
        _tile(
          context,
          6,
          widget.facility.facilityWebsite,
          'Website',
        ),
        const Divider(),
        _tile(
          context,
          7,
          widget.facility.facilityPhone,
          'Phone',
        ),
        const Divider(),
        _tile(
          context,
          8,
          widget.facility.facilityContraception,
          'Contraception Services',
        ),
        const Divider(),
        _tile(
          context,
          9,
          widget.facility.facilityPrep,
          'PrEP Services',
        ),
        const Divider(),
        _tile(
          context,
          10,
          widget.facility.facilityAbortion,
          'Abortion Services',
        ),
        const Divider(),
        _tile(
          context,
          11,
          widget.facility.facilityMenstrual,
          'Menstrual Services',
        ),
        const Divider(),
        _tile(
          context,
          12,
          widget.facility.facilitySTI,
          'STI Services',
        ),
        const Divider(),
        _tile(
          context,
          13,
          widget.facility.facilityART,
          'ART Services',
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:twyshe/classes/resource.dart';
import 'package:twyshe/utils/assist.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';

class ResourceInteractivePage extends StatefulWidget {
  final TwysheResource resource;

  const ResourceInteractivePage({super.key, required this.resource});

  @override
  State<ResourceInteractivePage> createState() =>
      _ResourceInteractivePageState();
}

class _ResourceInteractivePageState extends State<ResourceInteractivePage> {
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

  List<AccordionSection> _getAccordionContent() {
    return widget.resource.resourceQuestions
        .map<AccordionSection>((res) => AccordionSection(
              isOpen: false,
              contentVerticalPadding: 20,
              leftIcon:
                  const Icon(Icons.text_fields_rounded, color: Colors.white),
              header: Text(res.question,
                  style: const TextStyle(
                      color: Color(0xffffffff),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              content: Text(res.answer,
                  style: const TextStyle(
                      color: Color(0xff999999),
                      fontSize: 14,
                      fontWeight: FontWeight.normal)),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.resource.resourceName),
        ),
        body: Accordion(
          headerBorderColor: Colors.blueGrey,
          headerBorderColorOpened: Colors.transparent,
          // headerBorderWidth: 1,
          headerBackgroundColorOpened: Colors.green,
          contentBackgroundColor: Colors.white,
          contentBorderColor: Colors.green,
          contentBorderWidth: 3,
          contentHorizontalPadding: 20,
          scaleWhenAnimating: true,
          openAndCloseAnimation: true,
          headerPadding:
              const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
          sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
          sectionClosingHapticFeedback: SectionHapticFeedback.light,
          children: _getAccordionContent(),
        ));
  }
}

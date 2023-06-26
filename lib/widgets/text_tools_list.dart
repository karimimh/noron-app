import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';

import '../objects/tools.dart';

class ToolsList extends StatefulWidget {
  final NoronAppData noron;
  const ToolsList({super.key, required this.noron});

  @override
  State<ToolsList> createState() => _ToolsListState();
}

class _ToolsListState extends State<ToolsList> {
  List<bool> _isExpanded =
      List<bool>.generate(textTools.length, (index) => true);
  bool collapseAll = true;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.noron.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.noron.isExpanded = _isExpanded;
        return true;
      },
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            _navBar(),
            Expanded(
              child: SingleChildScrollView(
                child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _isExpanded[index] = !_isExpanded[index];
                      });
                    },
                    expandedHeaderPadding: const EdgeInsets.all(0),
                    elevation: 0,
                    dividerColor: Colors.white,
                    children: List.generate(textTools.length, (toolIndex) {
                      return ExpansionPanel(
                        backgroundColor: Colors.white,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(
                              textTools[toolIndex].title,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _isExpanded[toolIndex] =
                                    !_isExpanded[toolIndex];
                              });
                            },
                          );
                        },
                        body: Column(
                          children: List.generate(
                              textTools[toolIndex].items.length, (itemIndex) {
                            return ListTile(
                                contentPadding:
                                    const EdgeInsets.only(right: 25, left: 50),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      textTools[toolIndex]
                                          .items[itemIndex]
                                          .getFirstChoice(),
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    if (itemIndex <
                                        textTools[toolIndex].items.length - 1)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 6, bottom: 1),
                                        child: Container(
                                          height: 1,
                                          color: Colors.grey[300],
                                        ),
                                      )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).pop([
                                    textTools[toolIndex]
                                        .items[itemIndex]
                                        .getFirstChoice()
                                  ]);
                                });
                          }),
                        ),
                        isExpanded: _isExpanded[toolIndex],
                      );
                    })),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _navBar() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                //TODO
              },
              icon: const Icon(Icons.search)),
          Container(
            width: 20,
            height: 5,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(2.5))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    for (var i = 0; i < _isExpanded.length; i++) {
                      if (collapseAll) {
                        _isExpanded[i] = false;
                      } else {
                        _isExpanded[i] = true;
                      }
                    }
                    collapseAll = !collapseAll;
                  });
                },
                icon: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.black12),
                  child: Icon(
                    collapseAll
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                )),
          )
        ],
      ),
    );
  }
}

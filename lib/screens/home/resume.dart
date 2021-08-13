import 'package:flutter/material.dart';
import 'package:jellyflut/api/items.dart';
import 'package:jellyflut/components/poster/itemPoster.dart';
import 'package:jellyflut/globals.dart';
import 'package:jellyflut/models/category.dart';
import 'package:jellyflut/models/item.dart';
import 'package:jellyflut/shared/theme.dart';
import 'package:shimmer/shimmer.dart';

class Resume extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ResumeState();
  }
}

class _ResumeState extends State<Resume> {
  late bool hasError = false;
  late String error;
  Category? category;

  @override
  void initState() {
    getResumeItems()
        .then((Category _category) => setState(() => category = _category))
        .catchError((onError) {
      hasError = true;
      error = onError.toString();
    });
    super.initState();
  }

  @override
  Widget build(Object context) {
    return categoryBuilder();
  }

  /// Prevent from re-query the API on resize
  Widget categoryBuilder() {
    if (category != null && !hasError) {
      var _items = category!.items;
      if (_items.isNotEmpty) {
        return body(_items);
      } else {
        return Container();
      }
    }
    return placeholder();
  }

  Widget body(List<Item> items) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Resume',
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
        ),
        SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                var _item = items[index];
                return ItemPoster(
                  _item,
                  showLogo: true,
                  showParent: false,
                  clickable: true,
                  widgetAspectRatio: 16 / 9,
                );
              },
            ))
      ],
    );
  }

  Widget placeholder() {
    return Shimmer.fromColors(
        enabled: shimmerAnimation,
        baseColor: shimmerColor1,
        highlightColor: shimmerColor2,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(10, 15, 5, 5),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 15, 5, 5),
                    height: 30,
                    width: 70,
                    color: Colors.white30,
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                  child: Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                              height: 200,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 3,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 4, 8, 4),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          child: Container(
                                            height: 200,
                                            width: 200 * (2 / 3),
                                            color: Colors.white30,
                                          )))))),
                    ],
                  ))
            ]));
  }
}

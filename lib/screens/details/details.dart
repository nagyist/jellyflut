import 'package:flutter/material.dart';
import 'package:jellyflut/api/items.dart';
import 'package:jellyflut/components/musicPlayerFAB.dart';
import 'package:jellyflut/models/item.dart';
import 'package:jellyflut/models/itemType.dart';
import 'package:jellyflut/provider/listOfItems.dart';
import 'package:jellyflut/screens/details/components/photoItem.dart';
import 'package:jellyflut/screens/details/shared/palette.dart';
import 'package:jellyflut/screens/details/template/small_screens/details.dart'
    as phone;
import 'package:jellyflut/screens/details/template/large_screens/largeDetails.dart';
import 'package:jellyflut/screens/details/template/large_screens/tabletDetails.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../globals.dart';

class Details extends StatefulWidget {
  final Item item;
  final String heroTag;
  const Details({required this.item, required this.heroTag});

  @override
  State<StatefulWidget> createState() {
    return _DetailsState();
  }
}

class _DetailsState extends State<Details> with TickerProviderStateMixin {
  late PageController pageController;
  late MediaQueryData mediaQuery;
  late String heroTag;
  late Item item;
  late Future<List<dynamic>> itemsFuture;
  late Future<List<PaletteColor>> paletteColorFuture;

  // Items for photos
  late ListOfItems listOfItems;

  @override
  void initState() {
    heroTag = widget.heroTag;
    listOfItems = ListOfItems();
    item = widget.item;
    itemsFuture = getItemDelayed();
    paletteColorFuture = Palette.getPalette(widget.item, 'Primary');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MusicPlayerFAB(
      child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: item.type != ItemType.PHOTO
              ? responsiveBuilder()
              : PhotoItem(item: widget.item, heroTag: heroTag)),
    );
  }

  Widget responsiveBuilder() {
    return ScreenTypeLayout.builder(
        breakpoints: screenBreakpoints,
        mobile: (BuildContext context) => phone.Details(
              item: widget.item,
              itemToLoad: itemsFuture,
              paletteColorFuture: paletteColorFuture,
              heroTag: heroTag,
            ),
        tablet: (BuildContext context) => TabletDetails(
              item: widget.item,
              itemToLoad: itemsFuture,
              paletteColorFuture: paletteColorFuture,
              heroTag: heroTag,
            ),
        desktop: (BuildContext context) => LargeDetails(
            item: widget.item,
            itemToLoad: itemsFuture,
            paletteColorFuture: paletteColorFuture,
            heroTag: heroTag));
  }

  Future<List<dynamic>> getItemDelayed() async {
    final futures = <Future>[];
    futures.add(getItem(widget.item.id));
    futures.add(Future.delayed(Duration(milliseconds: 700)));
    return await Future.wait(futures);
  }
}

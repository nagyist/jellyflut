import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jellyflut/api/items.dart';
import 'package:jellyflut/models/item.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoItem extends StatefulWidget {
  final Item item;
  final List<Item>? items;
  final String heroTag;

  PhotoItem({Key? key, required this.item, required this.heroTag, this.items})
      : super(key: key);

  @override
  _PhotoItemState createState() => _PhotoItemState();
}

class _PhotoItemState extends State<PhotoItem> {
  late final PageController pageController;
  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }

  Widget photoItem() {
    if (widget.items != null && widget.items!.isEmpty) {
      return PhotoView(
        heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag),
        imageProvider: NetworkImage(getItemImageUrl(
            widget.item.correctImageId(), widget.item.correctImageTags()!)),
      );
    }
    return listOfPhoto(widget.items!);
  }

  Widget listOfPhoto(List<Item> items) {
    var startAt = items.indexOf(widget.item);
    pageController = PageController(initialPage: startAt);
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        var _item = items[index];
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(getItemImageUrl(
              _item.correctImageId(), _item.correctImageTags()!)),
          initialScale: PhotoViewComputedScale.contained,
        );
      },
      itemCount: items.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
          ),
        ),
      ),
      pageController: pageController,
    );
  }
}

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jellyflut/api/items.dart';
import 'package:jellyflut/api/show.dart';
import 'package:jellyflut/api/user.dart';
import 'package:jellyflut/components/carroussel.dart';
import 'package:jellyflut/models/category.dart';
import 'package:jellyflut/models/item.dart';
import 'package:jellyflut/components/favButton.dart';
import 'package:jellyflut/components/viewedButton.dart';
import 'package:jellyflut/provider/musicPlayer.dart';
import 'package:jellyflut/screens/details/listCollectionItem.dart';
import 'package:jellyflut/screens/details/listMusicItem.dart';
import 'package:jellyflut/screens/details/listVideoItem.dart';
import 'package:jellyflut/shared/shared.dart';

import '../../globals.dart';
import '../../main.dart';

class Collection extends StatefulWidget {
  final Item item;

  const Collection(this.item);

  @override
  State<StatefulWidget> createState() {
    return _CollectionState();
  }
}

const double gapSize = 20;

class _CollectionState extends State<Collection> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Category>(
      future: collectionItems(widget.item),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
              child: Column(
            children: [
              if (widget.item.isFolder && widget.item.type == "MusicAlbum")
                ListMusicItem(snapshot.data)
              else if (widget.item.isFolder && widget.item.type == "Season")
                ListVideoItem(snapshot.data)
              else
                ListCollectionItem(snapshot.data)
            ],
          ));
        } else {
          return Container();
        }
      },
    );
  }
}

Future collectionItems(Item item) {
  // If it's a series or a music album we get every item
  if (item.type == "Series" || item.type == "MusicAlbum") {
    return getCategory(parentId: item.id, limit: 100);
  } else {
    return getShowSeasonEpisode(item.seriesId, item.id);
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jellyflut/api/epub.dart';
import 'package:jellyflut/globals.dart';
import 'package:jellyflut/models/category.dart';
import 'package:jellyflut/models/item.dart';
import 'package:path_provider/path_provider.dart';

BaseOptions options = BaseOptions(
  connectTimeout: 60000,
  receiveTimeout: 60000,
  contentType: 'JSON',
);

Dio dio = Dio(options);

Future<List<Item>> getLatestMedia({
  String parentId,
  int limit = 16,
  String fields = 'PrimaryImageAspectRatio,BasicSyncInfo,Path',
  String enableImageTypes = 'Primary,Backdrop,Thumb',
  int imageTypeLimit = 1,
}) async {
  var queryParams = <String, dynamic>{};
  parentId != null ? queryParams['ParentId'] = parentId : null;
  queryParams['Limit'] = limit;
  queryParams['Fields'] = fields;
  queryParams['ImageTypeLimit'] = imageTypeLimit;
  queryParams['EnableImageTypes'] = enableImageTypes;
  queryParams['api_key'] = apiKey;
  queryParams['Content-Type'] = 'application/json';

  var url = '${server.url}/Users/${user.id}/Items/Latest';

  Response response;
  var items = <Item>[];
  try {
    response = await dio.get(url, queryParameters: queryParams);
    final List t = response.data;
    items = t.map((item) => Item.fromMap(item)).toList();
  } catch (e) {
    print(e);
  }
  return items;
}

Future<Category> getCategory({String parentId, int limit = 10}) async {
  var queryParams = <String, dynamic>{};
  queryParams['api_key'] = apiKey;
  queryParams['Limit'] = limit;
  if (parentId != null) queryParams['ParentId'] = parentId;

  var url = '${server.url}/Users/${user.id}/Items';

  Response response;
  var category = Category();
  try {
    response = await dio.get(url, queryParameters: queryParams);
    category = Category.fromMap(response.data);
  } catch (e) {
    print(e);
  }
  return category;
}

Future<String> getEbook(Item item) async {
  var hasStorage = await requestStorage();
  if (!hasStorage) {
    return null;
  }
  var queryParams = <String, dynamic>{};
  queryParams['api_key'] = apiKey;

  var url = '${server.url}/Items/${item.id}/Download?api_key=${apiKey}';
  // Directory storageDir = await getTemporaryDirectory();
  var storageDir = await getApplicationDocumentsDirectory();
  var storageDirPath = storageDir.path;
  if (Platform.isAndroid) {
    storageDirPath = '/storage/emulated/0/Download';
  }

  var dowloadPath = '${storageDirPath}/${item.name}.epub';
  await downloadFile(url, dowloadPath);
  return dowloadPath;
}

Future<bool> requestStorage() async {
  // var storage = await Permission.storage.request().isGranted;
  // if (storage) {
  //   return true;
  // } else {
  //   var permissionStatus = await Permission.storage.request();
  //   if (permissionStatus.isDenied) {
  //     return false;
  //   }
  // }
  return true;
}

Future<Map<String, dynamic>> viewItem(String itemId) async {
  var queryParams = <String, dynamic>{};
  // queryParams['DatePlayed'] = datePlayedFromDate(new DateTime.now());
  queryParams['api_key'] = apiKey;

  var url = '${server.url}/Users/${user.id}/PlayedItems/${itemId}';

  Response response;
  try {
    response = await dio.post(url, queryParameters: queryParams);
  } catch (e) {
    print(e);
  }
  return response.data;
}

Future<Map<String, dynamic>> unviewItem(String itemId) async {
  var queryParams = <String, dynamic>{};
  queryParams['api_key'] = apiKey;

  var url = '${server.url}/Users/${user.id}/PlayedItems/${itemId}';

  Response response;
  try {
    response = await dio.delete(url, queryParameters: queryParams);
  } catch (e) {
    print(e);
  }
  return response.data;
}

Future<Map<String, dynamic>> favItem(String itemId) async {
  var queryParams = <String, dynamic>{};
  // queryParams['DatePlayed'] = datePlayedFromDate(new DateTime.now());
  queryParams['api_key'] = apiKey;

  var url = '${server.url}/Users/${user.id}/FavoriteItems/${itemId}';

  Response response;
  try {
    response = await dio.post(url, queryParameters: queryParams);
  } catch (e) {
    print(e);
  }
  return response.data;
}

Future<Map<String, dynamic>> unfavItem(String itemId) async {
  var queryParams = <String, dynamic>{};
  queryParams['api_key'] = apiKey;

  var url = '${server.url}/Users/${user.id}/FavoriteItems/${itemId}';

  Response response;
  try {
    response = await dio.delete(url, queryParameters: queryParams);
  } catch (e) {
    print(e);
  }
  return response.data;
}

String datePlayedFromDate(DateTime dateTime) {
  return dateTime.year.toString() +
      dateTime.month.toString() +
      dateTime.day.toString() +
      dateTime.hour.toString() +
      dateTime.minute.toString() +
      dateTime.second.toString();
}

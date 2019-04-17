import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'dart:async';
import 'dart:typed_data';

class ImageDisplay extends StatelessWidget {
  final String uri;

  ImageDisplay(this.uri);

  _shareImage(path) async {
    await Share.file('esys image', 'esys.png', File(path).readAsBytesSync(), 'image/png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(child: PhotoView(imageProvider: FileImage(File(uri)))),
      floatingActionButton: new FloatingActionButton(
        onPressed: ()=>{
          _shareImage(uri)
        },
        tooltip: 'Share',
        child: new Icon(Icons.share),
      ),
    );
  }
}

class ImageListing extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImagesPageState();
  }
}

class _ImagesPageState extends State<ImageListing> {
  List<String> _imageUris = new List<String>();

  Future<void> getImages() async {
    String directoryMain =
        (await getExternalStorageDirectory()).path + '/Imaginate';

    Directory directory = new Directory(directoryMain);
    var files = await directory.list().toList();

    List<String> imageUris = new List<String>();
    for (var file in files) {
      imageUris.add(file.path);
    }
    setState(() {
      _imageUris = imageUris;
    });
  }

  imageFull(uri) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageDisplay(uri)),
    );
  }

  showBottomSheet(String path) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.open_in_new),
                      title: new Text('Open'),
                      onTap: () => {imageFull(path)}),
                  new ListTile(
                    leading: new Icon(Icons.delete),
                    title: new Text('Delete'),
                    onTap: () async => {
                          await File(path).delete(),
                          await getImages(),
                          Navigator.pop(context)
                        },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget gridViewCreate() {
    if (_imageUris.length > 0)
      return new GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          padding: const EdgeInsets.all(4.0),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: _imageUris.map((String uri) {
            return new GridTile(
              child: new InkResponse(
                enableFeedback: true,
                child: new Image.file(
                  File(uri),
                  fit: BoxFit.cover,
                ),
                onTap: () => showBottomSheet(uri),
              ),
            );
          }).toList());
    else
      return Text('No images yet.');
  }

  @override
  void initState() {
    getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Images"),
      ),
      body: Center(child: gridViewCreate()),
    );
  }
}

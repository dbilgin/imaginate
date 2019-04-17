import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui show Codec, FrameInfo, Image, ColorFilter;
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imaginate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Imaginate'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  bool _cancelActionVisible = false;
  var _persistentButtons;
  var _colorFilter;

  Color _currentColor = Colors.transparent;
  BlendMode _blendMode = BlendMode.color;

  Future getImage(ImageSource imageSource) async {
    var imageFile = await ImagePicker.pickImage(source: imageSource);
    setState(() {
      _image = imageFile;
      _cancelActionVisible = true;
      _persistentButtons = <Widget>[
        ButtonTheme(
          height: 50.0,
          child: RaisedButton(
            onPressed: () {
              setState(() => {
                    _colorFilter = null,
                    _blendMode = BlendMode.color,
                    _currentColor = Colors.transparent
                  });
            },
            child: Icon(
              Icons.format_clear,
              color: Colors.white,
            ),
          ),
        ),
        ButtonTheme(
          height: 50.0,
          child: RaisedButton(
            onPressed: () {
              colorDialog();
            },
            child: Icon(
              Icons.color_lens,
              color: Colors.white,
            ),
          ),
        ),
        ButtonTheme(
          height: 50.0,
          child: RaisedButton(
            onPressed: () {
              showPicker(context);
            },
            child: Icon(
              Icons.style,
              color: Colors.white,
            ),
          ),
        ),
      ];
    });
  }

  colorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _currentColor,
              onColorChanged: (color) => {
                    setState(() => {
                          _currentColor = color,
                          _colorFilter = ui.ColorFilter.mode(color, _blendMode)
                        }),
                    Navigator.of(context).pop()
                  },
            ),
          ),
        );
      },
    );
  }

  showPicker(BuildContext context) {
    String PickerData;
    PickerData = '[';
    for (var i = 0; i < BlendMode.values.length; i++) {
      PickerData += '"' + BlendMode.values[i].toString().split('.')[1] + '"';
      if (BlendMode.values.length - 1 > i) PickerData += ',';
    }
    PickerData += ']';
//    PickerData = '["Test", "Test2"]';
    new Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: new JsonDecoder().convert(PickerData)),
        changeToFirst: true,
        hideHeader: false,
        onConfirm: (Picker picker, List value) {
          var blendMode;
          if (value[0] == 0)
            blendMode = BlendMode.color;
          else
            blendMode = BlendMode.values[value[0]];
          setState(() => {
                _blendMode = blendMode,
                _colorFilter = ui.ColorFilter.mode(_currentColor, blendMode)
              });
        }).showModal(this.context);
  }

  @override
  Widget build(BuildContext context) {
    ScreenshotController screenshotController = ScreenshotController();
    var screenSize = MediaQuery.of(context).size;
    var renderImage;
    if (_image == null) {
      renderImage = Text(
        'Select an image',
      );
    } else {
      renderImage = Screenshot(
        controller: screenshotController,
        child: Container(
          height: screenSize.height - 150,
          width: screenSize.width - 50,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              colorFilter: _colorFilter,
              image: FileImage(_image),
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    captureImage() async {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions.containsKey(PermissionGroup.storage) &&
          permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        String directoryMain =
            (await getExternalStorageDirectory()).path + '/Imaginate';

        new Directory(directoryMain)
            .create(recursive: true)
            .then((Directory directory) {
          String fileName = DateTime.now().toIso8601String();
          String path = directoryMain + '/' + fileName + '.png';

          screenshotController.capture(path: path).then((File image) {
            setState(() {
              _image = null;
              _cancelActionVisible = false;
              _persistentButtons = null;
              _colorFilter = null;
              _blendMode = BlendMode.color;
              _currentColor = Colors.transparent;
            });
            Fluttertoast.showToast(
                msg: "Image saved to your phone",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: 16.0);
          }).catchError((onError) {
            print(onError);
            Fluttertoast.showToast(
                msg: "An error has occurred",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          AnimatedOpacity(
            opacity: _cancelActionVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200),
            // The green box needs to be the child of the AnimatedOpacity
            child: IconButton(
              icon: Icon(Icons.save),
              onPressed: captureImage,
            ),
          ),
          AnimatedOpacity(
            opacity: _cancelActionVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200),
            // The green box needs to be the child of the AnimatedOpacity
            child: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () => setState(() {
                    _image = null;
                    _cancelActionVisible = false;
                    _persistentButtons = null;
                    _colorFilter = null;
                    _blendMode = BlendMode.color;
                    _currentColor = Colors.transparent;
                  }),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[renderImage],
        ),
      ),
      persistentFooterButtons: _persistentButtons,
      floatingActionButton: AnimatedOpacity(
        opacity: _cancelActionVisible ? 0.0 : 1.0,
        duration: Duration(milliseconds: 200),
        // The green box needs to be the child of the AnimatedOpacity
        child: AnimatedFloatingActionButton(
          fabButtons: <Widget>[takePhotoFloat(), pickPhotoFloat()],
          colorStartAnimation: Colors.blue,
          colorEndAnimation: Colors.red,
          animatedIconData: AnimatedIcons.menu_close,
        ),
      ),
    );
  }

  Widget takePhotoFloat() {
    return Container(
      child: FloatingActionButton(
        onPressed: () => getImage(ImageSource.camera),
        tooltip: 'Take a photo',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget pickPhotoFloat() {
    return Container(
      child: FloatingActionButton(
        onPressed: () => getImage(ImageSource.gallery),
        tooltip: 'Pick an image',
        child: Icon(Icons.image),
      ),
    );
  }
}

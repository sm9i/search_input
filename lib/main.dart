import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());
final userList = [
  'Joocker',
  'Emma',
  'Joyce',
  'Jhon',
  'May',
  'MayAmanda',
  'Abby',
  'AbbyAnne',
  'Stella',
  'Kate',
  'KateLarissa',
  'KateLarissa',
  'Darius',
  'Master',
  'Annie',
  'Corki',
  'Ezreal',
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController;
  final GlobalKey _textKey = GlobalKey();
  StreamController<String> streamController = StreamController.broadcast();

  OverlayEntry overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool showOver = false;

  void createOv() {
    overlayEntry = OverlayEntry(
      builder: (_) => OverlayWidget(
        parentKey: _textKey,
        onTap: onTap,
        choose: streamController.stream,
        link: _layerLink,
      ),
    );
  }

  void onTap() {
    if (showOver) {
      showOver = false;
      overlayEntry.remove();
    }
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      createOv();
    });
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),
            CompositedTransformTarget(
              link: this._layerLink,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  key: _textKey,
                  controller: _textEditingController,
                  onChanged: _textChange,
                ),
              ),
            ),
            SizedBox(height: 20),
            RaisedButton(onPressed: () {
              Overlay.of(context).insert(overlayEntry);
            }),
            SizedBox(
              height: 300,
            ),
            Container(
              height: 600,
              color: Colors.redAccent,
            ),
            SizedBox(
              height: 300,
            ),
            Container(
              height: 600,
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  _textChange(String s) {
    if (s.contains("＠")) {
      var lastPosition = s.lastIndexOf("＠");
      var inputLast = s.substring(lastPosition + 1);
      var list = userList
          .where((w) => w.toLowerCase().contains(inputLast.toLowerCase()))
          .toList();

      print(inputLast);
      print(overlayEntry.maintainState);
      if (list.length > 0) {
        if (!showOver) Overlay.of(context).insert(overlayEntry);
        showOver = true;
        streamController.add(inputLast);
      } else {
        showOver = false;
        overlayEntry.remove();
      }
    } else {
      if (showOver) {
        overlayEntry.remove();
        showOver = false;
      }
    }
  }
}

class OverlayWidget/*<T>*/ extends StatelessWidget {
  //输入框的key 用来获取偏移和宽高
  final GlobalKey parentKey;

  //列表的item单击之后
  final GestureTapCallback onTap;

  //筛选的stream
  final Stream<String> choose;

  //用来绑定两个widget 使其 滑动的时候一样
  final LayerLink link;

//  final Widget Function(T t) child;

  const OverlayWidget({
    Key key,
    @required this.parentKey,
    @required this.onTap,
    @required this.link,
    @required this.choose,
//    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //位置
    final RenderBox box = parentKey.currentContext.findRenderObject();
    final Offset offset = box.localToGlobal(Offset.zero);
    final parentHeight = box.size.height;
    final parentWidth = box.size.width;
    final double top = offset.dy + parentHeight + 10;
    final double left = offset.dx;

    return Positioned(
      top: top,
      left: left,
      child: CompositedTransformFollower(
        link: link,
        offset: Offset(offset.dx, parentHeight + 10),
        child: Material(
          elevation: 4.0,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: parentWidth,
              maxHeight: 200,
            ),
            color: Colors.redAccent,
            child: StreamBuilder<String>(
                initialData: '',
                stream: choose,
                builder: (context, snp) {
                  var data = userList
                      .where((w) =>
                          w.toLowerCase().contains(snp.data.toLowerCase()))
                      .toList();
                  return ListView.builder(
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.touch_app),
                        title: Text('${data[index]}'),
                        onTap: () {
                          if (onTap != null) {
                            onTap();
                          }
                        },
                      );
                    },
                    itemCount: data.length,
                  );
                }),
          ),
        ),
      ),
    );
  }
}

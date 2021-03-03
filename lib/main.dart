import 'package:flutter/material.dart';

void main() => runApp(MyApp());

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

class Drawing {
  List<Offset> points;
  String name;
  Drawing(this.points,this.name);
}

class _MyHomePageState extends State<MyHomePage> {
  var state = "draw";
  List<Offset> points = <Offset>[];
  List savelist = [];
  String txt = "";
  String txtt = "";
  void rename(d,e) => setState(() {
    e.name = d;
  });
  void save (c) => setState(() {
    savelist.add(Drawing(List.of(points),c));
    points.clear();
    //print(savelist[0].points);
    state = "list";
  });
  @override
  Widget build(BuildContext context) {
    final Container sketchArea = Container(
      margin: EdgeInsets.all(1.0),
      alignment: Alignment.topLeft,
      color: Colors.blueGrey[50],
      child: CustomPaint(
        painter: Sketcher(points),
      ),
    );

    return state=="draw"
      ?Scaffold(
      appBar: AppBar(
        title: Text('Sketcher'),
      ),
      body: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            RenderBox box = context.findRenderObject();
            Offset point = box.globalToLocal(details.globalPosition);
            point = point.translate(0.0, -(AppBar().preferredSize.height));

            points = List.from(points)..add(point);
          });
        },
        onPanEnd: (DragEndDetails details) {
          points.add(null);
        },
        child: sketchArea,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              tooltip: 'clear Screen',
              backgroundColor: Colors.red,
              child: Icon(Icons.refresh),
              onPressed: () {
                setState(() => points.clear());
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              tooltip: 'clear Screen',
              backgroundColor: Colors.red,
              child: Icon(Icons.save),
              onPressed: (){
                return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text("Enter File name"),
                    content: TextField(
                      onChanged: (str) => txt = str,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          save (txt);
                          Navigator.of(ctx).pop();
                        },
                        child: Text("save"),

                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text("cancel"),


                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),


    )

    :Scaffold(
      appBar: AppBar(
        title: Text('Sketcher'),
      ),
      body: ListView(
        children:
          savelist.map((picture) {
            return Dismissible(
                key: Key(picture.name),
                onDismissed: (direction) {
                savelist.remove(picture);

                },
                background: Container(color: Colors.red),
                child: Container(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: () => setState(() {
                        state= "draw";
                        points = List.of(picture.points);
                      }),
                      onLongPress: () => setState(() {
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Enter new file name"),
                            content: TextField(
                              onChanged: (str) => txtt = str,
                            ),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  rename (txtt,picture);
                                  Navigator.of(ctx).pop();
                                },
                                child: Text("rename"),

                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text("cancel"),


                              )
                            ],
                          ),
                        );
                      }),

                      child: Text(picture.name),
                    )));
          }
        ).toList()),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        floatingActionButton: Stack(
        children: <Widget>[
      Align(
      alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          tooltip: 'go back to drawing',
          backgroundColor: Colors.red,
          child: Icon(Icons.add),
          onPressed: () {
            setState(() => state = "draw");
          },
        ),
      ),

      ]
      )
    );
  }
}

class Sketcher extends CustomPainter {
  final List<Offset> points;

  Sketcher(this.points);

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return oldDelegate.points != points;
  }

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }
}
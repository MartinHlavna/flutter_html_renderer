import 'package:flutter/material.dart';
import 'package:flutter_html_renderer/flutter_html_renderer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_html_renderer demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  static const String htmlDemo = '''
  <h2>YouTube embed code</h2>
  <iframe src="https://www.youtube.com/embed/b_sQ9bMltGU" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
  <h2>Image</h2>
  <img src="https://via.placeholder.com/150">
  <h2>Text</h2>
  <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum nec egestas erat, gravida tempus ipsum. Suspendisse ac pharetra quam. Ut pellentesque interdum est non sodales. Nunc nec lacus in neque dapibus cursus id eget neque. Curabitur luctus ante id orci eleifend, nec consequat arcu ullamcorper. Pellentesque quis mi ex. In mattis sollicitudin metus at molestie. Cras maximus felis eget leo lacinia egestas. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Maecenas ipsum ligula, sodales quis auctor in, vestibulum nec ligula. Pellentesque aliquet justo in faucibus bibendum. Praesent risus arcu, interdum eget elit id, dictum mollis ex. Pellentesque in sodales diam.</p>
  <p>Praesent quis augue vitae quam consectetur aliquet. Fusce sit amet orci quis leo porttitor vestibulum quis nec justo. Donec gravida in leo at rhoncus. Pellentesque faucibus porttitor sapien, sit amet interdum lacus lacinia at. Duis sagittis dolor massa, ut aliquet orci egestas a. Aenean orci metus, malesuada quis sapien in, dignissim ultrices elit. Nullam tincidunt dictum gravida. Mauris cursus libero enim, ultrices posuere sapien sodales ut. Suspendisse lacinia odio id fringilla pharetra. Aliquam iaculis augue ac enim porta, pulvinar hendrerit nibh rutrum. Donec quis lorem eget augue interdum malesuada. Etiam tincidunt sed diam et lacinia. Fusce nec lacus tellus. Vestibulum odio magna, molestie et orci sit amet, porta ullamcorper nisl. Donec porta quam in molestie laoreet.</p>
  <p>Duis pretium suscipit euismod. Donec sodales risus ut felis porttitor rhoncus. Cras ullamcorper egestas lacus id euismod. Maecenas aliquet tellus odio, eget vulputate orci consequat quis. Duis interdum, ipsum eget rutrum scelerisque, dolor justo malesuada enim, eget tempus purus magna vitae lorem. Maecenas quis neque a purus tempor scelerisque vel ut libero. Suspendisse posuere nisl ut varius molestie.</p>
 ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("flutter_html_renderer demo")),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 8),
          children: [
            HtmlRenderer(
              initialHtmlString: htmlDemo,
            ),
          ],
        ));
  }
}

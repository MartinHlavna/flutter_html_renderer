# flutter_html_renderer

Simple HTML renderer for flutter. Converts HTML into Widgets.

Warning: This is alpha version! It is not recommended to use in production projects as API may still change!

## Why

Pub now offers variety of HTML parsing plugins. In time of creation of this plugin, there was no available solution that had all of the following points:

* Simple and understandable codebase
* Optimized rendering
* Extensibility
* Robust HTML implementation

## Installation
To use this plugin, add `flutter_html_renderer` as a [dependency in your `pubspec.yaml` file](https://flutter.io/platform-plugins/).

## Example

``` dart
// IMPORT PACKAGE
import 'package:flutter_html_renderer/flutter_html_renderer.dart';

// INITIALIZE FROM HTML STRING.
Widget widget = HtmlRenderer(
    initialHtmlString: htmlString,
),

// INITIALIZE FROM HTML DOM NODES.
import 'package:html/parser.dart' as htmlParser;
HtmlRenderer(
    initialNodes: htmlParser.parse(htmlString).nodes, //you may have NodeList from other custom logic
),

// ENABLE WIDGET CACHE.
Widget widget = HtmlRenderer(
    initialHtmlString: htmlString,
    keepAlive: true
),

// ADD CUSTOM LINK CLICK HANDLER
HtmlRenderer(
    initialHtmlString: htmlString,
    linkHandler: (String url) async {
      print("Custom link handling");
      return true;
  },
),

// CUSTOM RENDERING FOR DIV
class DivDescriptor extends ElementDescriptor {
      const DivDescriptor()
      : super(
        name: 'div',
        supported: true,
        isBlock: true,
      );
    
      @override
      Future<Widget> render(
          dom.Element element,
          BuildContext context,
          WidgetsFactory widgetsFactory,
          LinkHandler linkHandler,
          RenderingContext renderingContext) async {
            if(element.attributes['id'] == 'someSpecialFeature'){
                return Text('To use this feature visit our website!');
            }
            return null; // use default rendering
        );
      }
    
}

// REPLACE DEFAULT DESCRIPTOR WITH CUSTOM
WidgetsFactory.allElements['div'] = DivDescriptor(); 
// INITIALIZE RENDERER NORMALY
HtmlRenderer(
    initialHtmlString: htmlString,
    keepAlive: true,
    linkHandler: (String url) async {
      print("Custom link handling");
      return true;
  },
),
```

### List of currently supported elements

* Block level
  * body
  * html
  * address
  * article
  * aside
  * blockquote
  * details
  * dialog
  * div
  * dl
  * dt
  * fieldset
  * figcaption
  * figure
  * footer
  * h1, h2, h3, h4, h5, h6
  * header
  * hgroup
  * main
  * nav
  * p
  * section
  * iframe (partial support: only iframes embeding YouTube videos)
  
* Inline
  * abbr
  * acronym
  * cite
  * img
  * label
  * span

## Roadmap

* v 0.2.0 - support for formating elements (b, i, strong, ...)
* v 0.3.0 - support for ul, ol, li
* v 0.4.0 - support for tables
* v 0.5.0 - polishing of default rendering of all element supported so far

Support for other tags will have to analyzed first. Roadmap may change depending on reported bugs and/or feature requests.

* Elements that have planned support, but are not yet in roadmap
  * iframe
  * video
  * audio

Form elements are currently not planned before first stable release. 

CSS and advanced styling support is not planned before first stable release
## TODOs

* Add tests

## Contribution and Support

* Contributions are welcome!
* If you want to contribute code please create a PR
* If you find a bug or want a feature, please fill an issue

library flutter_html_renderer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

/// Factory for rewriting HTML into widget sets.
/// Despite changes in HTML5, this renderer uses HTML4 logic of
/// block and inline elements. This is mainly because of simplicity.
/// Block level elements are by default rendered wrapper of their
/// inner content with no padding nor margin. Block level elements are always
/// rendered on a new row.
/// On contrary, inline elements are organized into flows. Inline elements
/// in the same flow are rendered inside [Row] widgets. If there is block
/// element as a sibling of inline elements, block element marks the end
/// of the currentFlow. By applying same logic, block elements are rendered as
/// single element in its own flow.
///
/// For example:
///
/// <img>
/// <span id='firstSpan'></span>
/// <p></p>
/// <span id='secondSpan'></span
///
/// would be rendered as:
/// Flow 1:
/// img span#firstSpan
/// Flow 2:
/// p
/// Flow 3:
/// span#secondSpan
///
/// These flows are rendered inside [Column] widget. Widget tree is also
/// optimized as following:
///
/// 1. If flow contains only one element, no [Row] widget is added
/// 2. If flow doesn't have any sibling no [Column] widget is added
///
/// For example:
/// <img src='http://example.com/foo.jpg'>
/// <span id='firstSpan'>Lorem ipsum</span>
/// <p>Docor sit</p>
/// <span id='secondSpan'>net</span>
///
/// Renders as following Widget tree:
///
/// [Column]
///   [Row]
///     [TransitionToImage]
///       [AdvancedNetworkImage]
///     [Text] = Lorem ipsum
///   [Text] - Docor sit
///   [Text] - net
///
/// To extend rendering of tag, extend [ElementDescriptor] class, implement
/// [ElementDescriptor]#render method and replace descriptor in
/// [WidgetsFactory]#allElements map.
class WidgetsFactory {
  static const List<ElementDescriptor> _blockLevelElements = [
    ElementDescriptor(name: 'body', supported: true, isBlock: true),
    ElementDescriptor(name: 'html', supported: true, isBlock: true),
    ElementDescriptor(name: 'head', supported: false, isBlock: true),
    ElementDescriptor(name: 'address', supported: true, isBlock: true),
    ElementDescriptor(name: 'article', supported: true, isBlock: true),
    ElementDescriptor(name: 'aside', supported: true, isBlock: true),
    ElementDescriptor(name: 'blockquote', supported: true, isBlock: true),
    ElementDescriptor(name: 'details', supported: true, isBlock: true),
    ElementDescriptor(name: 'dialog', supported: true, isBlock: true),
    ElementDescriptor(name: 'dd', supported: false, isBlock: true),
    ElementDescriptor(name: 'div', supported: true, isBlock: true),
    ElementDescriptor(name: 'dl', supported: true, isBlock: true),
    ElementDescriptor(name: 'dt', supported: true, isBlock: true),
    ElementDescriptor(name: 'fieldset', supported: true, isBlock: true),
    ElementDescriptor(name: 'figcaption', supported: true, isBlock: true),
    ElementDescriptor(name: 'figure', supported: true, isBlock: true),
    ElementDescriptor(name: 'footer', supported: true, isBlock: true),
    ElementDescriptor(name: 'form', supported: false, isBlock: true),
    HeaderDescriptor(name: 'h1'),
    HeaderDescriptor(name: 'h2'),
    HeaderDescriptor(name: 'h3'),
    HeaderDescriptor(name: 'h4'),
    HeaderDescriptor(name: 'h5'),
    HeaderDescriptor(name: 'h6'),
    HeaderDescriptor(name: 'header'),
    ElementDescriptor(name: 'hgroup', supported: true, isBlock: true),
    ElementDescriptor(name: 'hr', supported: false, isBlock: true),
    ElementDescriptor(name: 'li', supported: false, isBlock: true),
    ElementDescriptor(name: 'main', supported: true, isBlock: true),
    ElementDescriptor(name: 'nav', supported: true, isBlock: true),
    ElementDescriptor(name: 'ol', supported: false, isBlock: true),
    ElementDescriptor(name: 'p', supported: true, isBlock: true),
    ElementDescriptor(name: 'pre', supported: false, isBlock: true),
    ElementDescriptor(name: 'section', supported: true, isBlock: true),
    ElementDescriptor(name: 'table', supported: false, isBlock: true),
    ElementDescriptor(name: 'ul', supported: false, isBlock: true),
  ];

  static const List<ElementDescriptor> _inlineElements = [
    AnchorDescriptor(),
    ElementDescriptor(name: 'abbr', supported: true, isInline: true),
    ElementDescriptor(name: 'acronym', supported: true, isInline: true),
    ElementDescriptor(name: 'audio', supported: false, isInline: true),
    ElementDescriptor(name: 'b', supported: false, isInline: true),
    ElementDescriptor(name: 'bdi', supported: false, isInline: true),
    ElementDescriptor(name: 'bdo', supported: false, isInline: true),
    ElementDescriptor(name: 'big', supported: false, isInline: true),
    ElementDescriptor(name: 'br', supported: false, isInline: true),
    ElementDescriptor(name: 'button', supported: false, isInline: true),
    ElementDescriptor(name: 'canvas', supported: false, isInline: true),
    ElementDescriptor(name: 'cite', supported: true, isInline: true),
    ElementDescriptor(name: 'code', supported: false, isInline: true),
    ElementDescriptor(name: 'data', supported: false, isInline: true),
    ElementDescriptor(name: 'datalist', supported: false, isInline: true),
    ElementDescriptor(name: 'del', supported: false, isInline: true),
    ElementDescriptor(name: 'dfn', supported: false, isInline: true),
    ElementDescriptor(name: 'em', supported: false, isInline: true),
    ElementDescriptor(name: 'embed', supported: false, isInline: true),
    ElementDescriptor(name: 'i', supported: false, isInline: true),
    ElementDescriptor(name: 'iframe', supported: false, isInline: true),
    ImgDescriptor(),
    ElementDescriptor(name: 'input', supported: false, isInline: true),
    ElementDescriptor(name: 'ins', supported: false, isInline: true),
    ElementDescriptor(name: 'kbd', supported: false, isInline: true),
    ElementDescriptor(name: 'label', supported: true, isInline: true),
    ElementDescriptor(name: 'map', supported: false, isInline: true),
    ElementDescriptor(name: 'mark', supported: false, isInline: true),
    ElementDescriptor(name: 'meter', supported: false, isInline: true),
    ElementDescriptor(name: 'noscript', supported: true, isInline: true),
    ElementDescriptor(name: 'object', supported: false, isInline: true),
    ElementDescriptor(name: 'output', supported: false, isInline: true),
    ElementDescriptor(name: 'picture', supported: false, isInline: true),
    ElementDescriptor(name: 'progress', supported: false, isInline: true),
    ElementDescriptor(name: 'q', supported: false, isInline: true),
    ElementDescriptor(name: 'ruby', supported: false, isInline: true),
    ElementDescriptor(name: 's', supported: false, isInline: true),
    ElementDescriptor(name: 'samp', supported: false, isInline: true),
    ElementDescriptor(name: 'script', supported: false, isInline: true),
    ElementDescriptor(name: 'select', supported: false, isInline: true),
    ElementDescriptor(name: 'slot', supported: false, isInline: true),
    ElementDescriptor(name: 'small', supported: false, isInline: true),
    ElementDescriptor(name: 'span', supported: true, isInline: true),
    ElementDescriptor(name: 'strong', supported: false, isInline: true),
    ElementDescriptor(name: 'sub', supported: false, isInline: true),
    ElementDescriptor(name: 'sup', supported: false, isInline: true),
    ElementDescriptor(name: 'svg', supported: false, isInline: true),
    ElementDescriptor(name: 'template', supported: false, isInline: true),
    ElementDescriptor(name: 'textarea', supported: false, isInline: true),
    ElementDescriptor(name: 'time', supported: false, isInline: true),
    ElementDescriptor(name: 'u', supported: false, isInline: true),
    ElementDescriptor(name: 'tt', supported: false, isInline: true),
    ElementDescriptor(name: 'var', supported: false, isInline: true),
    ElementDescriptor(name: 'video', supported: false, isInline: true),
    ElementDescriptor(name: 'wbr', supported: false, isInline: true),
  ];

  /// Map of all recognized elements. Key is the name of the element.
  static final Map<String, ElementDescriptor> allElements =
      new Map.fromIterable(
          <ElementDescriptor>[]
            ..addAll(_blockLevelElements)
            ..addAll(_inlineElements),
          key: (dynamic el) => el.name);

  /// Convert HTML to WidgetTree
  Future<Widget> nodeListToWidgets(dom.NodeList nodes, BuildContext context,
      {LinkHandler linkHandler, RenderingContext renderingContext}) async {
    assert(nodes?.isNotEmpty ?? false);
    renderingContext ??= RenderingContext();
    List<Widget> widgets = [];
    List<Widget> currentFlow = [];
    for (dom.Node node in nodes) {
      if (node is dom.Text) {
        if (node.text.trim() != "") {
          if (renderingContext.hasAnchorParent) {
            currentFlow.add(Text(
              node.text,
              style: Theme.of(context).textTheme.body2,
            ));
          } else if (renderingContext.hasHeaderParent) {
            currentFlow.add(Text(
              node.text,
              style: Theme.of(context).textTheme.headline.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
              textAlign: TextAlign.start,
              softWrap: true,
            ));
          } else {
            currentFlow.add(Text(
              node.text,
              style: Theme.of(context).textTheme.body1,
            ));
          }
        }
      } else if (node is dom.Element) {
        ElementDescriptor descriptor = allElements[node.localName];
        if (descriptor == null) {
          print('Warning: unknown HTML element ${node.localName} ignored');
        } else if (descriptor.supported) {
          if (descriptor.isBlock) {
            if (currentFlow.isNotEmpty) {
              _addFlowToWidgets(widgets, currentFlow);
              currentFlow = [];
            }
            widgets.add(await parseNode(
                node, descriptor, context, renderingContext,
                linkHandler: linkHandler));
          } else {
            currentFlow.add(await parseNode(
                node, descriptor, context, renderingContext,
                linkHandler: linkHandler));
          }
        }
      }
    }
    if (currentFlow.isNotEmpty) {
      _addFlowToWidgets(widgets, currentFlow);
    }
    return widgets.length > 1
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgets,
          )
        : widgets.length > 0 ? widgets[0] : Container();
  }

  /// Add currentFlow to list of widgets
  void _addFlowToWidgets(List<Widget> widgets, List<Widget> currentFlow) {
    if (currentFlow.length > 1) {
      widgets.add(Row(children: currentFlow));
    } else {
      widgets.add(currentFlow[0]);
    }
  }

  /// Parse single node of HTML
  Future<Widget> parseNode(
    dom.Element node,
    ElementDescriptor descriptor,
    BuildContext context,
    RenderingContext renderingContext, {
    LinkHandler linkHandler,
  }) async {
    Widget children;
    Widget rendered = await descriptor.render(
        node, context, this, linkHandler, renderingContext);
    if (rendered == null) {
      if (node.nodes.isNotEmpty) {
        children = await nodeListToWidgets(node.nodes, context,
            linkHandler: linkHandler);
      }
      if (children == null) {
        return Container();
      }
      return children;
    }
    return rendered;
  }
}

/// Descriptor of Html element. Provides information, about how should
/// be widget rendered
class ElementDescriptor {
  /// HTML name of the element
  final String name;

  /// Flag that provides information if this element is supported
  final bool supported;

  /// Flag that provides information if this is an inline element
  final bool isInline;

  /// Flag that provides ionformation if this is a block element
  final bool isBlock;

  /// Render element. If this returns null, default rendering is used
  Future<Widget> render(
      dom.Element element,
      BuildContext context,
      WidgetsFactory widgetsFactory,
      LinkHandler linkHandler,
      RenderingContext renderingContext) async {
    return null;
  }

  const ElementDescriptor({
    this.name,
    this.supported,
    this.isInline = false,
    this.isBlock = false,
  });
}

/// Descriptor of the <a> tag.
/// This will pass a copy of the [RenderingContext] with hasAnchorParent=true
/// to default rendering
/// of child nodes, and wraps them in a [GestureDetector].
///
/// On click:
/// If linkHandler is not null, it is called. If is null, or returns false,
/// we will check if link can be launched in browser and potentially launch
/// browser
class AnchorDescriptor extends ElementDescriptor {
  const AnchorDescriptor()
      : super(
          name: 'a',
          supported: true,
          isInline: true,
          isBlock: false,
        );

  @override
  Future<Widget> render(
      dom.Element element,
      BuildContext context,
      WidgetsFactory widgetsFactory,
      LinkHandler linkHandler,
      RenderingContext renderingContext) async {
    String url = element.attributes['href'];
    Widget children;
    renderingContext = RenderingContext.copy(renderingContext);
    renderingContext.hasAnchorParent = true;
    if (element.nodes.isNotEmpty) {
      children = await widgetsFactory.nodeListToWidgets(element.nodes, context,
          linkHandler: linkHandler);
    }
    children ??= Container();

    return GestureDetector(
      child: children,
      onTap: () async {
        if (linkHandler == null || !(await linkHandler(url))) {
          if (await canLaunch(url)) {
            await launch(url);
          }
        }
      },
    );
  }
}

/// <h1> -<h6> and <header> descriptor.
/// This will pass a copy of the [RenderingContext] with hasHeaderParent=true
/// to default rendering
/// of child nodes
class HeaderDescriptor extends ElementDescriptor {
  const HeaderDescriptor({String name})
      : super(
          name: name,
          supported: true,
          isInline: false,
          isBlock: true,
        );

  @override
  Future<Widget> render(
      dom.Element element,
      BuildContext context,
      WidgetsFactory widgetsFactory,
      LinkHandler linkHandler,
      RenderingContext renderingContext) async {
    Widget children;
    renderingContext = RenderingContext.copy(renderingContext);
    renderingContext.hasHeaderParent = true;
    if (element.nodes.isNotEmpty) {
      children = await widgetsFactory.nodeListToWidgets(element.nodes, context,
          linkHandler: linkHandler, renderingContext: renderingContext);
    }
    children ??= Container();
    return Padding(
      child: children,
      padding: EdgeInsets.symmetric(vertical: 5),
    );
  }
}

/// Descriptor for the <img> tag.
/// If src attribute is null or empty, returns empty [Container]
///
/// If src starts with data:, it is treated as base64 encoded image and returns
/// [Image] widget.
///
/// Otherwise, [AdvancedNetworkImage] wrapped in a [TransitionToImage] is used
class ImgDescriptor extends ElementDescriptor {
  const ImgDescriptor()
      : super(
          name: 'img',
          supported: true,
          isInline: true,
          isBlock: false,
        );

  @override
  Future<Widget> render(
      dom.Element element,
      BuildContext context,
      WidgetsFactory widgetsFactory,
      LinkHandler linkHandler,
      RenderingContext renderingContext) async {
    String src = element.attributes['src'];
    if (src == null || src.trim().isEmpty) {
      return Container();
    }
    if (src.startsWith('data:')) {
      final UriData data = Uri.parse(src).data;
      return Image.memory(
        data.contentAsBytes(),
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    }
    return TransitionToImage(
      image: AdvancedNetworkImage(
        src,
        useDiskCache: true,
      ),
      loadingWidget: Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
      fit: BoxFit.contain,
      placeholder: const Icon(Icons.refresh),
    );
  }
}

/// Current rendering context
class RenderingContext {
  bool hasAnchorParent = false;
  bool hasHeaderParent = false;

  RenderingContext();

  RenderingContext.copy(RenderingContext other) {
    hasAnchorParent = other.hasAnchorParent;
  }
}

/// Function that handles click on elements wrapped in <a>
typedef Future<bool> LinkHandler(String url);

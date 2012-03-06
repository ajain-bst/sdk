
class _SVGFEOffsetElementImpl extends _SVGElementImpl implements SVGFEOffsetElement {
  _SVGFEOffsetElementImpl._wrap(ptr) : super._wrap(ptr);

  SVGAnimatedNumber get dx() => _wrap(_ptr.dx);

  SVGAnimatedNumber get dy() => _wrap(_ptr.dy);

  SVGAnimatedString get in1() => _wrap(_ptr.in1);

  // From SVGFilterPrimitiveStandardAttributes

  SVGAnimatedLength get height() => _wrap(_ptr.height);

  SVGAnimatedString get result() => _wrap(_ptr.result);

  SVGAnimatedLength get width() => _wrap(_ptr.width);

  SVGAnimatedLength get x() => _wrap(_ptr.x);

  SVGAnimatedLength get y() => _wrap(_ptr.y);

  // From SVGStylable

  SVGAnimatedString get _svgClassName() => _wrap(_ptr.className);

  CSSStyleDeclaration get style() => _wrap(_ptr.style);

  CSSValue getPresentationAttribute(String name) {
    return _wrap(_ptr.getPresentationAttribute(_unwrap(name)));
  }
}

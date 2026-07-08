import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sz_core/src/core.dart';

abstract class SZBase<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver {
  String? _dialogMsg;

  void showDialog(String msg) {
    setState(() {
      _dialogMsg = msg;
    });
  }

  void hideDialog() {
    setState(() {
      _dialogMsg = null;
    });
  }

  Future<A?> open<A extends Widget>(A dyClass) {
    return SZCore.open(context, dyClass);
  }

  void onResume() {}

  void onPaused() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onResume();
    });
  }

  @override
  void dispose() {
    super.dispose();
    onPaused();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      onResume();
    } else if (state == AppLifecycleState.paused) {
      onPaused();
    }
  }

  Widget buildContent(BuildContext context);

  List<Widget> belowContent(BuildContext context) => [];

  Positioned _internalOverLayWidget(String dialogMsg, bool forDialog) {
    return Positioned.fill(
      child: Container(
        color: forDialog ? Colors.black54 : Colors.transparent,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16),
            // Space between the indicator and text
            SZText(
              dialogMsg,
              color: forDialog ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ],
        ),
      ),
    );
  }
}

abstract class SZActivity<T extends StatefulWidget> extends SZBase<T> {
  @nonVirtual
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ...belowContent(context),
            buildContent(context),
            if (_dialogMsg != null) _internalOverLayWidget(_dialogMsg!, true),
          ],
        ),
      ),
    );
  }
}

abstract class SZFragment<T extends StatefulWidget> extends SZBase<T> {
  @nonVirtual
  @override
  Widget build(BuildContext context) {
    // Provider.of<LocaleProvider>(context);
    // return buildContent(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ...belowContent(context),
        buildContent(context),
        if (_dialogMsg != null) _internalOverLayWidget(_dialogMsg!, true),
      ],
    );
  }

  List<Widget>? getMenus() {
    return null;
  }
}

class SZText extends StatelessWidget {
  const SZText(
    this.text, {
    super.key,
    this.color = Colors.white,
    this.fontSize,
    this.maxLine = 500,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.decoration = TextDecoration.none,
    this.required = false,
    this.shadows,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.decorationColor,
    this.showNA = false,
    this.fullRow = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.height,
  });

  final bool required;
  final bool showNA;
  final bool fullRow;
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLine;
  final TextAlign textAlign;
  final TextDecoration decoration;
  final List<Shadow>? shadows;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? decorationColor;
  final double? height;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (required || icon != null || fullRow) {
      return Row(
        mainAxisSize: fullRow ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: iconSize ?? ((fontSize ?? 12.sp) * 1.3), // ?? 12.sp,
              color: iconColor ?? color,
            ),
          if (icon != null) SizedBox(width: 2),
          fullRow ? Flexible(child: _text()) : _text(),
          if (required) SizedBox(width: 2),
          if (required)
            SZText(
              "*",
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: (fontSize ?? 12.sp),
            ),
        ],
      );
    }
    return _text();
  }

  Text _text() {
    return Text(
      (!showNA) ? text : (text.isEmpty ? "N/A" : text),
      maxLines: maxLine,
      // textScaleFactor: 1.0,
      // text Sca ler: const TextSca ler.linear(1.0),
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        shadows: shadows,
        color: color,
        fontSize: (fontSize ?? 12.sp),
        height: height,
        fontWeight: fontWeight,
        decorationColor: decorationColor,
        decoration: decoration,
      ),
    );
  }
}

class SZButton extends StatelessWidget {
  const SZButton({
    super.key,
    required this.text,
    required this.onClick,
    this.width = double.infinity,
    this.height,
    this.fontSize,
    this.textColor = Colors.white,
    this.btnColor,
    this.borderColor,
    this.iconColor,
    this.radius,
    this.icon,
    this.iconSize,
    this.fontWeight = FontWeight.w600,
    this.enable,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
  });

  final IconData? icon;
  final String text;
  final double width;
  final double? height;
  final double? iconSize;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final Color? btnColor;
  final Color? iconColor;
  final Color? borderColor;
  final double? radius;
  final EdgeInsets padding;
  final VoidCallback? onClick;
  final bool? enable;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClick,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: padding,
        splashFactory: InkRipple.splashFactory,
        overlayColor: Colors.blue.withAlpha(77),
        // overlayColor: Colors.blue.withOpacity(0.3),
        backgroundColor: (enable ?? onClick != null)
            ? btnColor ?? Theme.of(context).primaryColor
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 12.sp),
          side: (enable ?? onClick != null)
              ? BorderSide(
                  color:
                      borderColor ??
                      (btnColor ?? Theme.of(context).primaryColor),
                  width: 0.5,
                )
              : BorderSide.none,
        ),
        minimumSize: Size(width, height ?? 40.sp),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: (icon == null)
          ? SZText(
              text,
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize ?? 16.sp,
                  color: onClick != null
                      ? (iconColor ?? textColor)
                      : Colors.blueGrey.shade300,
                ),
                SizedBox(width: 5),
                SZText(
                  text,
                  color: onClick != null ? textColor : Colors.blueGrey.shade300,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ],
            ),
    );
  }
}

class SZIconButton extends StatelessWidget {
  const SZIconButton({
    super.key,
    required this.onClick,
    required this.icon,
    this.widget,
    this.bgColor,
    this.color = Colors.white,
    this.size,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.onLongClick,
  }); //assert(icon == null || child==null,'any one needed from icon & child')

  final BorderRadius borderRadius;
  final IconData? icon;
  final Widget? widget;
  final Color? bgColor;
  final VoidCallback? onClick;
  final VoidCallback? onLongClick;
  final Color color;
  final double? size;
  final EdgeInsets? padding, margin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      onLongPress: onLongClick,
      child: Container(
        margin: margin ?? EdgeInsets.symmetric(vertical: 5),
        padding: padding ?? EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: bgColor ?? Theme.of(context).primaryColor,
          borderRadius: borderRadius,
        ),
        child: widget != null
            ? IconButton(
                icon: widget!,
                iconSize: size,
                constraints: BoxConstraints(),
                visualDensity: VisualDensity(horizontal: -3.4, vertical: -3.4),
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                color: color,
                onPressed: onClick,
              )
            : Icon(icon, size: size, color: color),
      ),
    );
  }
}

class SZTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType inputType;
  final TextInputAction? inputAction;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isEnable;
  final int maxLength;
  final String? label;
  final VoidCallback? onSuffixTap;
  final bool isFocus;
  final Color? fontColor;
  final Color borderColor;
  final bool isSelection;
  final String? initialValue;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final EdgeInsets? contentPadding;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final double? fontSize;
  final bool readOnly;
  final bool? showCursor;

  const SZTextField({
    super.key,
    required this.hint,
    this.inputAction,
    this.inputType = TextInputType.text,
    this.controller,
    this.isEnable = true,
    this.isFocus = true,
    this.isSelection = true,
    this.label,
    this.maxLength = 100,
    this.onSuffixTap,
    this.borderColor = Colors.black,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.fontColor = Colors.black,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.initialValue,
    this.focusNode,
    this.fontSize,
    this.readOnly = false,
    this.showCursor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      showCursor: showCursor,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      initialValue: initialValue,
      canRequestFocus: isFocus,
      obscureText: obscureText,
      cursorColor: fontColor,
      keyboardType: inputType,
      textInputAction: inputAction,
      controller: controller,
      focusNode: focusNode,
      enableInteractiveSelection: isSelection,
      style: TextStyle(
        color: fontColor,
        fontWeight: FontWeight.w600,
        fontSize: fontSize ?? 12.sp,
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w600,
        ),
        enabled: isEnable,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: Colors.blueGrey),
        suffixIcon: suffixIcon == null
            ? null
            : InkWell(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, color: Colors.blueGrey),
              ),
        contentPadding:
            contentPadding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        // disabledBorder: OutlineInputBorder(
        //     borderSide: BorderSide(color: borderColor),
        //     borderRadius: BorderRadius.circular(8)),
        fillColor: isEnable ? Colors.white : Colors.blueGrey.shade100,
        // enabledBorder: OutlineInputBorder(
        //     borderSide: BorderSide(color: borderColor),
        //     borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isEnable ? borderColor : Colors.blueGrey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: isEnable ? borderColor : Colors.blueGrey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
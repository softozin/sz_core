import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sz_core/src/core.dart';

/// Base activity class used by SZ Core.
///
/// Provides:
/// - Activity lifecycle callbacks (`onResume`, `onPaused`)
/// - Loading dialog support (`showDialog`, `hideDialog`)
/// - Simplified navigation (`open`)
/// - Automatic app lifecycle observation
/// - Overlay support for loading indicators
///
/// Extend this class instead of `State<T>` to use SZ Core activity features.
///
/// Example:
/// ```dart
/// class HomeActivity extends StatefulWidget {
///   const HomeActivity({super.key});
///
///   @override
///   State<HomeActivity> createState() => _HomeActivityState();
/// }
///
/// class _HomeActivityState extends SZBase<HomeActivity> {
///   @override
///   void onResume() {
///     super.onResume();
///     loadData();
///   }
///
///   @override
///   Widget buildContent(BuildContext context) {
///     return const Center(
///       child: Text('Home Screen'),
///     );
///   }
/// }
/// ```
abstract class SZBase<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver {

  /// Current loading dialog message.
  String? _dialogMsg;

  /// Displays a loading overlay with the specified message.
  ///
  /// Example:
  /// ```dart
  /// showDialog('Loading data...');
  /// ```
  void showDialog(String msg) {
    setState(() {
      _dialogMsg = msg;
    });
  }

  /// Hides the currently displayed loading overlay.
  ///
  /// Example:
  /// ```dart
  /// hideDialog();
  /// ```
  void hideDialog() {
    setState(() {
      _dialogMsg = null;
    });
  }

  /// Opens a new activity.
  ///
  /// This is a convenience wrapper around `SZCore.open()`.
  ///
  /// Example:
  /// ```dart
  /// await open(
  ///   const LoginActivity(),
  ///   onlyOne: true,
  /// );
  /// ```
  Future<A?> open<A extends Widget>(A dyClass, {
    bool finish = false,
    bool onlyOne = false,
  }) {
    return SZCore.open(context, dyClass,finish: finish,onlyOne: onlyOne);
  }

  /// Called when the activity becomes visible or the app resumes.
  ///
  /// Override this method to refresh data or restart listeners.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onResume() {
  ///   loadData();
  /// }
  /// ```
  void onResume() {}

  /// Called when the activity becomes inactive or the app is paused.
  ///
  /// Override this method to stop timers or save state.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onPaused() {
  ///   stopLocationTracking();
  /// }
  /// ```
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


  /// Builds the main content of the activity.
  ///
  /// This method must be implemented by subclasses.
  Widget buildContent(BuildContext context);

  /// Returns widgets displayed below the main content.
  ///
  /// Default implementation returns an empty list.
  List<Widget> belowContent(BuildContext context) => [];

  /// Internal loading overlay widget used by SZ Core.
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

/// Base class for full-screen activities in SZ Core.
///
/// `SZActivity` provides:
/// - Automatic `SafeArea` handling
/// - Full-screen layout support
/// - Loading overlay management
/// - Background color using the application's primary color
/// - Support for additional overlay widgets via [belowContent]
///
/// Extend this class when creating top-level screens or pages.
///
/// Example:
/// ```dart
/// class HomeActivity extends StatefulWidget {
///   const HomeActivity({super.key});
///
///   @override
///   State<HomeActivity> createState() => _HomeActivityState();
/// }
///
/// class _HomeActivityState extends SZActivity<HomeActivity> {
///   @override
///   Widget buildContent(BuildContext context) {
///     return const Center(
///       child: Text('Home Screen'),
///     );
///   }
/// }
/// ```
abstract class SZActivity<T extends StatefulWidget> extends SZBase<T> {
  /// Builds the activity layout.
  ///
  /// This implementation is final and should not be overridden.
  /// Override [buildContent] instead.
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

/// Base class for reusable content sections and embedded screens in SZ Core.
///
/// Unlike [SZActivity], `SZFragment` does not provide a `SafeArea`
/// or background container, making it suitable for:
/// - Tab pages
/// - Nested views
/// - Reusable content components
/// - Dashboard sections
///
/// It includes:
/// - Loading overlay support
/// - Lifecycle callbacks inherited from [SZBase]
/// - Optional menu support via [getMenus]
///
/// Example:
/// ```dart
/// class DashboardFragment extends StatefulWidget {
///   const DashboardFragment({super.key});
///
///   @override
///   State<DashboardFragment> createState() =>
///       _DashboardFragmentState();
/// }
///
/// class _DashboardFragmentState
///     extends SZFragment<DashboardFragment> {
///   @override
///   Widget buildContent(BuildContext context) {
///     return const Center(
///       child: Text('Dashboard'),
///     );
///   }
/// }
/// ```
abstract class SZFragment<T extends StatefulWidget> extends SZBase<T> {
  /// Builds the fragment layout.
  ///
  /// This implementation is final and should not be overridden.
  /// Override [buildContent] instead.
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

  /// Returns optional menu widgets for the fragment.
  ///
  /// Override this method if the fragment provides custom menu actions.
  ///
  /// Returns `null` by default.
  List<Widget>? getMenus() {
    return null;
  }
}

/// A customizable text widget used throughout SZ Core.
///
/// `SZText` provides a simplified and consistent way to display text with
/// support for icons, required indicators, text styling, and layout options.
///
/// Features:
/// - Custom text color and size
/// - Font weight and text alignment
/// - Optional leading icon
/// - Required field indicator
/// - Optional `N/A` display for empty values
/// - Full row layout support
/// - Shadow and decoration support
///
/// Example:
/// ```dart
/// const SZText(
///   'Hello World',
///   fontSize: 16,
///   fontWeight: FontWeight.bold,
/// );
///
/// const SZText(
///   'Email',
///   required: true,
///   icon: Icons.email,
/// );
/// ```
class SZText extends StatelessWidget {
  /// Creates an SZ Core text widget.
  ///
  /// The [text] parameter is required and represents the text to display.
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

/// A customizable button widget used throughout SZ Core.
///
/// `SZButton` provides a consistent button style with support for
/// icons, custom colors, sizing, borders, and enable/disable states.
///
/// Features:
/// - Custom button and text colors
/// - Optional leading icon
/// - Adjustable size and border radius
/// - Enable/disable support
/// - Custom padding and typography
///
/// Example:
/// ```dart
/// SZButton(
///   text: 'Login',
///   onClick: () {
///     login();
///   },
/// );
///
/// SZButton(
///   text: 'Delete',
///   icon: Icons.delete,
///   btnColor: Colors.red,
///   onClick: deleteItem,
/// );
/// ```
class SZButton extends StatelessWidget {

  /// Creates an SZ Core button widget.
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

/// A customizable icon button widget used throughout SZ Core.
///
/// `SZIconButton` provides a simple way to display clickable icons
/// with optional background color, custom widget content, padding,
/// margin, and long press support.
///
/// Features:
/// - Click and long-click callbacks
/// - Optional background color
/// - Custom icon size and color
/// - Circular or custom border radius
/// - Support for replacing the icon with a custom widget
///
/// Example:
/// ```dart
/// SZIconButton(
///   icon: Icons.edit,
///   onClick: () {
///     editProfile();
///   },
/// );
///
/// SZIconButton(
///   icon: Icons.delete,
///   bgColor: Colors.red,
///   color: Colors.white,
///   onClick: deleteItem,
///   onLongClick: showDeleteConfirmation,
/// );
///
/// SZIconButton(
///   widget: const CircularProgressIndicator(),
///   icon: Icons.refresh,
///   onClick: refreshData,
/// );
/// ```
class SZIconButton extends StatelessWidget {
  /// Creates an SZ Core icon button.
  ///
  /// Either [icon] or [widget] can be used for the button content.
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


/// A customizable text input widget used throughout SZ Core.
///
/// `SZTextField` provides a simplified and consistent text field
/// implementation with support for:
/// - Prefix and suffix icons
/// - Read-only mode
/// - Password fields
/// - Custom keyboard types
/// - Focus handling
/// - Text capitalization
/// - Multi-line input
/// - Character limits
///
/// Example:
/// ```dart
/// SZTextField(
///   hint: 'Enter your name',
///   controller: nameController,
/// );
///
/// SZTextField(
///   hint: 'Password',
///   obscureText: true,
///   suffixIcon: Icons.visibility,
///   onSuffixTap: togglePasswordVisibility,
/// );
/// ```
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

  /// Creates an SZ Core text field widget.
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



/// A customizable generic dropdown widget used throughout SZ Core.
///
/// `SZDropDown` provides a simple and reusable dropdown implementation
/// with support for:
/// - Generic item types
/// - Custom item text conversion
/// - Enable/disable state
/// - Custom colors
/// - Adjustable dimensions
///
/// Example:
/// ```dart
/// SZDropDown<Pair>(
///   true,
///   selectedItem,
///   items,
///   (value) {
///     setState(() {
///       selectedItem = value;
///     });
///   },
///   toStringConvert: (item) => item.name,
/// );
/// ```
///
/// Example with String values:
/// ```dart
/// SZDropDown<String>(
///   true,
///   selectedCountry,
///   countries,
///   (value) => selectedCountry = value,
/// );
/// ```
class SZDropDown<T> extends StatelessWidget {
  final bool isEnable;
  final T? value;
  final List<T> values;
  final ValueChanged<T?>? onChanged;
  final String Function(T value)? toStringConvert;
  final Color? dropDownBgColor;
  final Color? bgColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  /// Creates an SZ Core dropdown widget.
  const SZDropDown(this.isEnable, this.value, this.values, this.onChanged,
      {super.key, this.toStringConvert,
        this.dropDownBgColor,
        this.bgColor,
        this.borderColor,
        this.textColor,
        this.height = 48,
        this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: isEnable ? (bgColor ?? Colors.white) : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: borderColor ?? Colors.grey.shade400),
      ),
      child: DropdownButton<T>(
        menuMaxHeight: MediaQuery.of(context).size.height * 0.50,
        borderRadius: BorderRadius.circular(12.0),
        iconEnabledColor: Theme.of(context).primaryColorLight,
        dropdownColor: dropDownBgColor ?? Colors.grey.shade100,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey.shade400,
        ),
        isExpanded: true,
        value: value,
        hint: SZText("-- SELECT --",
          color: textColor ?? Theme.of(context).primaryColorLight,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        style: TextStyle(
            color: textColor ?? Theme.of(context).primaryColorLight,
            fontSize: 12,
            fontWeight: FontWeight.w400),
        underline: const SizedBox(),
        onChanged: isEnable ? onChanged : null,
        items: values.map<DropdownMenuItem<T>>((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: SZText(toStringConvert != null
                  ? toStringConvert!(value)
                  : value.toString(),
              color: textColor ?? Theme.of(context).primaryColorLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          );
        }).toList(),
      ),
    );
  }
}


/// A customizable autocomplete widget with asynchronous search support.
///
/// `SZAutoComplete` allows users to search and select items from a
/// dynamically loaded list.
///
/// Features:
/// - Asynchronous search support
/// - Generic item types
/// - Custom display text formatting
/// - Optional pre-selected value
/// - Custom colors and sizing
/// - Enable/disable state
///
/// Example:
/// ```dart
/// SZAutoComplete<Pair>(
///   isEnable: true,
///   value: selectedUser,
///   onSearch: (keyword) async {
///     return await fetchUsers(keyword);
///   },
///   displayText: (item) => item.name,
///   onSelected: (item) {
///     selectedUser = item;
///   },
/// );
/// ```
class SZAutoComplete<T extends Object> extends StatefulWidget {
  final bool isEnable;
  final T? value;
  final Future<List<T>> Function(String keyword) onSearch;
  final String Function(T item) displayText;
  final ValueChanged<T>? onSelected;

  final Color? dropDownBgColor;
  final Color? bgColor;
  final Color? textColor;
  final Color? borderColor;

  final double? fontSize;
  final double? width;
  final double height;
  final String hintText;

  /// Creates an SZ Core autocomplete widget.
  const SZAutoComplete({
    super.key,
    required this.isEnable,
    required this.onSearch,
    required this.displayText,
    this.onSelected,
    this.value,
    this.dropDownBgColor,
    this.bgColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 48,
    this.fontSize,
    this.hintText = "-- SELECT --",
  });

  @override
  State<SZAutoComplete<T>> createState() =>
      _SZAutoCompleteState<T>();
}

class _SZAutoCompleteState<T extends Object>
    extends State<SZAutoComplete<T>> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.value != null) {
      _controller.text = widget.displayText(widget.value as T);
    }
  }

  @override
  void didUpdateWidget(covariant SZAutoComplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _controller.text = widget.value == null
          ? ""
          : widget.displayText(widget.value as T);
    }
  }

  Future<void> _openSearchSheet() async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchBottomSheet<T>(
        onSearch: widget.onSearch,
        displayText: widget.displayText,
        title: widget.hintText,
        text:  _controller.text,
        dropDownBgColor: widget.dropDownBgColor,
        textColor: widget.textColor,
      ),
    );

    if (selected != null) {
      _controller.text = widget.displayText(selected);

      widget.onSelected?.call(selected);

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.isEnable ? _openSearchSheet : null,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: widget.isEnable
                ? (widget.bgColor ?? Colors.white)
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.borderColor ?? Colors.grey.shade400,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _controller.text.isEmpty
                      ? widget.hintText
                      : _controller.text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _controller.text.isEmpty
                        ? Colors.grey
                        : (widget.textColor ??
                        Theme.of(context).primaryColorLight),
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBottomSheet<T extends Object> extends StatefulWidget {
  final Future<List<T>> Function(String keyword) onSearch;
  final String Function(T item) displayText;
  final String title;
  final String text;
  final Color? dropDownBgColor;
  final Color? textColor;

  const _SearchBottomSheet({
    required this.onSearch,
    required this.displayText,
    required this.title,
    required this.text,
    this.dropDownBgColor,
    this.textColor,
  });

  @override
  State<_SearchBottomSheet<T>> createState() =>
      _SearchBottomSheetState<T>();
}

class _SearchBottomSheetState<T extends Object>
    extends State<_SearchBottomSheet<T>> {
  final TextEditingController _controller = TextEditingController();

  List<T> _items = [];
  bool _loading = false;

  Future<void> _search(String keyword) async {
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      final result = await widget.onSearch(keyword);

      if (mounted) {
        setState(() {
          _items = result;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .75,
      decoration: BoxDecoration(
        color: widget.dropDownBgColor ?? Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, _) =>
                const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = _items[index];

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.displayText(item),
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
# SZ Core

[![pub package](https://img.shields.io/pub/v/sz_core?style=for-the-badge)](https://pub.dev/packages/sz_core)

A lightweight Flutter package that provides reusable widgets, responsive sizing, utility methods, dialogs, navigation helpers, and a simple API caller to speed up Flutter application development.

## Features

- ✅ Responsive UI scaling (`.w`, `.h`, `.r`, `.sp`)
- ✅ Base Activity & Fragment architecture
- ✅ Built-in API caller (GET,POST,PUT,PATCH & DELETE)
- ✅ Toasts, dialogs & pickers
- ✅ Navigation helper
- ✅ Phone, Website & WhatsApp launcher
- ✅ Keyboard helper
- ✅ Date & Time formatting
- ✅ Random Dark Color generator
- ✅ Hex Color extension

---

## Included Classes

- `SZCore`
- `SZActivity`
- `SZFragment`
- `SZApiCaller`
- `SZApiSetting`
- `SZShow`
- `SZText`
- `SZButton`
- `SZIconButton`
- `SZTextField`

---

# Installation

Add the package to your `pubspec.yaml`.

```yaml
dependencies:
  sz_core: ^2.0.0
```

Then run

```bash
flutter pub get
```

---

# Import

```dart
import 'package:sz_core/sz_core.dart';
```

---

# Initialization

Initialize `SZCore` before `runApp()`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SZCore.init();

  runApp(const MyApp());
}
```

### With Base URL

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SZCore.init(
    baseURL: "https://example.com/api/",
  );

  runApp(const MyApp());
}
```

### Custom API Settings

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SZApiSetting.init(
    "https://example.com/api/",
    keyStatus: "status",
    keyMessage: "message",
    keyData: "data",
    keyInternet: "internet", 
    defaultHeader: {
      "Authorization": "Bearer TOKEN"
    }
  );

  await SZCore.init();

  runApp(const MyApp());
}
```

You can update custom setting directly from anywhere
like 

```dart
SZApiSetting.defaultHeader = {
   "Authorization": "Bearer UPDATED TOKEN"
};
```

---

# Responsive Size

`SZCore.init()` automatically calculates the screen scale.

Use the extensions anywhere.

```dart
Container(
  width: 120.w,
  height: 60.h,
  padding: EdgeInsets.all(12.r),
  child: SZText(
    "Hello",
    fontSize: 16.sp,
  ),
)
```

| Extension | Description          |
|-----------|----------------------|
| `.w`      | Width scaling        |
| `.h`      | Height scaling       |
| `.r`      | Radius scaling       |
| `.sp`     | Responsive font size |

---

# SZActivity

Replace `State` with `SZActivity`.

Replace `build()` with `buildContent()`.

```dart
class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends SZActivity<HomeActivity> {

  @override
  Widget buildContent(BuildContext context) {
    return const SizedBox();
  }
}
```

### Available Methods

```dart
showDialog("Loading...");

hideDialog();

open(const SecondActivity());

onResume();

onPaused();
```

---

# SZFragment

Replace `State` with `SZFragment`.

Replace `build()` with `buildContent()`.

```dart
class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends SZFragment<HomeFragment> {

  @override
  Widget buildContent(BuildContext context) {
    return const SizedBox();
  }
}
```

### Available Methods

```dart
showDialog("Loading...");

hideDialog();

open(const SecondActivity());

onResume();

onPaused();
```

---

# SZCore

## Open Activity

Open a new activity:

```dart
await SZCore.open(
  context,
  const HomeActivity(),
);
```

### Parameters

| Parameter | Default | Description                                                                            |
|-----------|---------|----------------------------------------------------------------------------------------|
| `finish`  | `false` | Closes the current activity before opening the new activity.                           |
| `onlyOne` | `false` | Clears all previous activities and opens the new activity as the only active activity. |

### Example

```dart
await SZCore.open(
  context,
  const HomeActivity(),
  finish: true,
  onlyOne: true,
);
```

---

## Hide Keyboard

```dart
SZCore.hideKeyboard(context);
```

---

## Screen Size

```dart
final size = await SZCore.getScreenSize();

print(size.width);
print(size.height);
```

---

## Date Formatting

Server format

```dart
SZCore.formattedDate(DateTime.now());
```

Output

```
2026-07-07
```

Display format

```dart
SZCore.formattedDate(
  DateTime.now(),
  server: false,
);
```

Output

```
7 Jul 2026
```

---

## Time Formatting

Server

```dart
SZCore.formattedTime(DateTime.now());
```

Output

```
14:30
```

Display

```dart
SZCore.formattedTime(
  DateTime.now(),
  server: false,
);
```

Output

```
2:30 PM
```

---

## Random Dark Color

```dart
Color color = SZCore.getRandomDarkColor();
```

---

## Debug Log

```dart
SZCore.printLog("Hello");
```

Prints only in Debug mode.

---

## Open Phone Dialer

```dart
SZCore.openCall("9876543210");
```

---

## Open Website

```dart
SZCore.openWebsite(
  "https://flutter.dev",
);
```

---

## Open WhatsApp

```dart
SZCore.openWhatsApp(
  "919876543210",
  message: "Hello",
);
```

---

# Hex Color Extension

```dart
Color color = "#2196F3".toColor();
```

---

# SZShow

## Toast

```dart
SZShow.toast("Saved Successfully");
```

Custom

```dart
SZShow.toast(
  "Error",
  bg: Colors.red,
  color: Colors.white,
  size: 14,
);
```

---

## Dialog

```dart
SZShow.dialog(
  context,
  "Success",
  "Data Saved Successfully",
);
```

Two Buttons

```dart
SZShow.dialog(
  context,
  "Delete",
  "Delete this record?",
  btn1: "Yes",
  btn2: "No",
  b1Click: () {

  },
  b2Click: () {

  },
);
```

Custom Widget

```dart
SZShow.dialog(
  context,
  "",
  "",
  buildContent: (setState) {
    return const Text("Custom Widget");
  },
);
```

---

## Date Picker

```dart
SPair date = await SZShow.dateSelect(
  context,
  null,
);
```

---

## Time Picker

```dart
SPair time = await SZShow.timeSelect(
  context,
  null,
);
```

---

## Year Picker

```dart
int year = await SZShow.yearSelect(
  context,
  2025,
);
```

---

# SZApiCaller

Supports both GET and POST requests.

## GET Request

```dart
SZApiCaller(
  context,
  this,
  1,
  null,
  "Loading...",
  "users",
).then((response, key) {

});
```

---

## POST Request

```dart
SZApiCaller(
  context,
  this,
  2,
  jsonEncode(data),
  "Please wait...",
  "login",
).then((response, key) {

});
```

## PUT,PATCH,DELETE Request
You can use below enum

```dart
enum SZMethod { get, post, delete, put, patch }
```

```dart
SZApiCaller(
  context,
  this,
  2,
  jsonEncode(data),
  "Please wait...",
  "login",
  method = SZMethod.put
).then((response, key) {

});
```

---

## Custom Header

```dart
SZApiCaller(
  context,
  this,
  1,
  null,
  null,
  "users",
  customHeader: {
    "Authorization": "Bearer TOKEN"
  },
).then((response, key) {

});
```

---

## Logout Callback

```dart
SZCore.logoutCallback = () {
  // Navigate to Login Screen
};
```

If the API response contains **"session expire"**, the callback is automatically invoked.

---

# Requirements

- Flutter SDK >= 3.0.0

---

# Contributing

Contributions, issues, and feature requests are welcome.

---

# License

This project is licensed under the MIT License. See the LICENSE file for details.
import 'package:sz_core/src/core.dart';
import 'package:sz_core/src/model.dart';
import 'package:sz_core/sz_core_platform_interface.dart';
import 'package:sz_core/src/widget.dart';
import 'package:flutter/material.dart';

class SZShow {
  static Future<String?> toast(
    String message, {
    Color bg = Colors.green,
    Color color = Colors.white,
    double? size,
    double duration = 2,
  }) {
    return SzCorePlatform.instance.showToast(
      message,
      bg,
      color,
      size ?? 12,
      duration,
    );
  }

  static void dialog(
    BuildContext context,
    String title,
    String msg, {
    String btn1 = "OK",
    String? btn2,
    VoidCallback? b1Click,
    VoidCallback? b2Click,
    bool closeOnB1 = true,
    bool closeOnB2 = true,
    Widget Function(StateSetter setDialogState)? buildContent,
  }) {
    showGeneralDialog(
      barrierColor: Colors.black.withAlpha(128),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: PopScope(
              canPop: false,
              // False will prevent and true will allow to dismiss
              child: AlertDialog(
                title: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Medium',
                  ),
                  textAlign: TextAlign.start,
                ),
                titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                content: buildContent == null
                    ? Text(
                        msg,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Medium',
                        ),
                        textAlign: TextAlign.start,
                      )
                    : StatefulBuilder(
                        builder: (context, setState) => buildContent(setState),
                      ),
                actions: [
                  if (btn2 != null)
                    InkWell(
                      onTap: () {
                        if (closeOnB2) {
                          Navigator.pop(context);
                        }
                        if (b2Click != null) {
                          b2Click();
                        }
                      },
                      child: SZText(
                        btn2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  if (btn2 != null) SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      if (closeOnB1) {
                        Navigator.pop(context);
                      }
                      if (b1Click != null) {
                        b1Click();
                      }
                    },
                    child: SZText(
                      btn1,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
    );
  }

  static Future<SPair> dateSelect(
    BuildContext context,
    SPair? selectedDate, {
    bool futureAllow = false,
    bool pastAllow = true,
    bool todayAllow = true,
  }) async {
    final today = todayAllow
        ? DateTime.now()
        : DateTime.now().add(Duration(days: 1));
    final eighteenY = DateTime(today.year, today.month, today.day);
    final lastY = DateTime(today.year + 20, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (selectedDate == null || selectedDate.id.isEmpty)
          ? eighteenY
          : DateTime.tryParse(selectedDate.id),
      firstDate: pastAllow ? DateTime(1900) : eighteenY,
      lastDate: futureAllow ? lastY : eighteenY,
    );
    if (picked != null) {
      return SPair(
        SZCore.formattedDate(picked),
        SZCore.formattedDate(picked, server: false),
      );
    } else {
      return SPair('', '');
    }
  }

  static Future<SPair> timeSelect(
    BuildContext context,
    SPair? selectedTime, {
    bool futureAllow = false,
    bool pastAllow = true,
  }) async {
    final now = TimeOfDay.now();
    // final lastY = DateTime(today.year + 20, today.month, today.day);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (selectedTime == null || selectedTime.id.isEmpty)
          ? now
          : TimeOfDay.fromDateTime(
              DateTime.tryParse(selectedTime.id) ?? DateTime.now(),
            ),
      // firstDate: pastAllow ? DateTime(1900) : eighteenY,
      // lastDate: futureAllow ? lastY : eighteenY,
    );
    if (picked != null) {
      DateTime dt = DateTime.now();
      dt = DateTime(dt.year, dt.month, dt.day, picked.hour, picked.minute);
      return SPair(
        SZCore.formattedTime(dt),
        SZCore.formattedTime(dt, server: false),
      );
    } else {
      return SPair('', '');
    }
  }

  static Future<int> yearSelect(
    BuildContext context,
    int selectedYear, {
    bool futureAllow = false,
    bool pastAllow = true,
    bool currentAllow = true,
  }) async {
    final today = currentAllow ? DateTime.now().year : DateTime.now().year - 1;
    final eighteenY = DateTime(today);
    final lastY = DateTime(today + 20);

    return await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Select Year"),
              content: SizedBox(
                height: 250, // Adjust height to fit the YearPicker
                width: 300,
                child: YearPicker(
                  firstDate: pastAllow ? DateTime(1900) : eighteenY,
                  lastDate: futureAllow ? lastY : eighteenY,
                  // initialDate: DateTime(_selectedYear==0?DateTime.now().year:_selectedYear),
                  selectedDate: DateTime(
                    selectedYear == 0 ? DateTime.now().year : selectedYear,
                  ),
                  onChanged: (DateTime dateTime) {
                    Navigator.pop(
                      context,
                      dateTime.year,
                    ); // Return selected year
                  },
                ),
              ),
            );
          },
        ) ??
        0;
  }
}

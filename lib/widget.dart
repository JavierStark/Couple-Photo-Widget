import 'package:home_widget/home_widget.dart';

Future<void> updateWidget() async {
  await HomeWidget.saveWidgetData<String>('title', 'Updated from Flutter!');
  await HomeWidget.updateWidget(
    name: 'HomeWidgetProvider',
    iOSName: 'HomeWidgetExtension', // only relevant on iOS
  );
}

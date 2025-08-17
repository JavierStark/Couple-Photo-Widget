import 'package:home_widget/home_widget.dart';

Future<void> updateWidget(String path) async {
  await HomeWidget.saveWidgetData<String>('title', 'Updated from Flutter!');
  await HomeWidget.saveWidgetData('widgetImagePath', path);
  await HomeWidget.updateWidget(name: 'MainWidgetProvider');
}

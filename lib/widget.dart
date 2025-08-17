import 'package:home_widget/home_widget.dart';

Future<void> updateWidget(String path) async {
  await HomeWidget.saveWidgetData('widgetImagePath', path);
  await HomeWidget.updateWidget(name: 'MainWidgetProvider');
}

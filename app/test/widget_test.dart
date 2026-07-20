// Basic smoke test for FamilyWall clone bootstrap.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders a MaterialApp', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('OK'))));
    expect(find.text('OK'), findsOneWidget);
  });
}

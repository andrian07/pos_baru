import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/customer_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/product_screen.dart';
import '../screens/sales_screen.dart';
import 'app_sidebar.dart';

void handleAppNavSelect(BuildContext context, int index, AppUser user) {
  final Widget? target = switch (index) {
    0 => DashboardScreen(user: user),
    1 => SalesScreen(user: user),
    2 => ProductScreen(user: user),
    3 => CustomerScreen(user: user),
    4 => HistoryScreen(user: user),
    _ => null,
  };

  if (target != null) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => target));
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${appNavItems[index].label} belum tersedia')),
  );
}

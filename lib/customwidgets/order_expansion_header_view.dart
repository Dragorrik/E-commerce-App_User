import 'package:ecom_basic_user/models/order_expansion_item.dart';
import 'package:ecom_basic_user/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class OrderExpansionHeaderView extends StatelessWidget {
  final OrderExpansionHeader header;
  const OrderExpansionHeaderView({super.key, required this.header,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Order ID:${header.orderId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Date: ${getFormattedDate(header.orderDate.timestamp.toDate())}'),
            Text('Order Status: ${header.orderStatus}'),
          ],
        ),
      ),
    );
  }
}

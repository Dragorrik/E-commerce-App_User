import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_basic_user/models/address_model.dart';
import 'package:ecom_basic_user/models/order_model.dart';
import 'package:ecom_basic_user/pages/order_successful_page.dart';
import 'package:ecom_basic_user/pages/view_product_page.dart';
import 'package:ecom_basic_user/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../models/date_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class CheckoutPage extends StatefulWidget {
  static const String routeName = '/checkout';
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late OrderProvider orderProvider;
  late CartProvider cartProvider;
  late UserProvider userProvider;
  String paymentMethodGroupValue = PaymentMethod.cod;
  String? city;
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final zipCodeController = TextEditingController();
  @override
  void didChangeDependencies() {
    orderProvider = Provider.of<OrderProvider>(context);
    cartProvider = Provider.of<CartProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _setAddress();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          buildHeaderSection('Product Info'),
          buildProductInfoSection(),
          buildHeaderSection('Order Summery'),
          buildOrderSummerySection(),
          buildHeaderSection('Delivery Address'),
          buildDeliveryAddressSection(),
          buildHeaderSection('Payment Method'),
          buildPaymentMethodSection(),
          ElevatedButton(
            onPressed: _saveOrder,
            child: const Text('PLACE ORDER'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kShrineBrown900
            ),
          )
        ],
      ),
    );
  }

  Widget buildHeaderSection(String title) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget buildProductInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: cartProvider.cartList
              .map((cartModel) => ListTile(
                    title: Text(cartModel.productModel.productName),
                    trailing: Text(
                        '${cartModel.quantity}x$currencySymbol${cartModel.productModel.calculatePriceAfterDiscount()}', style: const TextStyle(fontSize: 18,),),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget buildOrderSummerySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ListTile(
              title: const Text('Sub-Total'),
              trailing:
                  Text('$currencySymbol${cartProvider.getCartSubTotal()}', style: const TextStyle(fontSize: 18,),),
            ),
            ListTile(
              title: Text(
                  'Discount(${orderProvider.orderConstantModel.discount}%)'),
              trailing: Text('-$currencySymbol${orderProvider.getDiscountAmount(cartProvider.getCartSubTotal())}', style: const TextStyle(fontSize: 18,),),
            ),
            ListTile(
              title: Text('VAT(${orderProvider.orderConstantModel.vat}%)'),
              trailing: Text('$currencySymbol${orderProvider.getVatAmount(cartProvider.getCartSubTotal())}', style: const TextStyle(fontSize: 18,),),
            ),
            ListTile(
              title: const Text('Delivery Charge'),
              trailing: Text('$currencySymbol${orderProvider.orderConstantModel.deliveryCharge}', style: const TextStyle(fontSize: 18,),),
            ),
            const Divider(
              height: 2,
              color: Colors.black,
            ),
            ListTile(
              title: const Text(
                'Grand Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: Text('$currencySymbol${orderProvider.getGrandTotal(cartProvider.getCartSubTotal())}', style: const TextStyle(fontSize: 22,),),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeliveryAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: addressLine1Controller,
              decoration: InputDecoration(
                hintText: 'Address Line 1',
              ),
            ),
            TextField(
              controller: addressLine2Controller,
              decoration: InputDecoration(
                hintText: 'Address Line 2 (optional)',
              ),
            ),
            TextField(
              controller: zipCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Zip Code',
              ),
            ),
            DropdownButton<String>(
              value: city,
              hint: const Text('Select your city'),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  city = value;
                });
              },
              items: cities
                  .map((city) => DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Radio<String>(
              value: PaymentMethod.cod,
              groupValue: paymentMethodGroupValue,
              onChanged: (value) {
                setState(() {
                  paymentMethodGroupValue = value!;
                });
              },
            ),
            const Text(PaymentMethod.cod),
            Radio<String>(
              value: PaymentMethod.online,
              groupValue: paymentMethodGroupValue,
              onChanged: (value) {
                setState(() {
                  paymentMethodGroupValue = value!;
                });
              },
            ),
            const Text(PaymentMethod.online),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    zipCodeController.dispose();
    super.dispose();
  }

  void _setAddress() {
    if(userProvider.userModel != null) {
      final user = userProvider.userModel!;
      if(user.addressModel != null) {
        final address = user.addressModel!;
        addressLine1Controller.text = address.addressLine1;
        addressLine2Controller.text = address.addressLine2 ?? '';
        zipCodeController.text = address.zipcode;
        city = address.city;
      }
    }
  }

  void _saveOrder() async {
    if (addressLine1Controller.text.isEmpty) {
      showMsg(context, 'Please provide your address');
      return;
    }
    if (zipCodeController.text.isEmpty) {
      showMsg(context, 'Please provide your zip code');
      return;
    }
    if (city == null) {
      showMsg(context, 'Please select your city');
      return;
    }
    EasyLoading.show(status: 'Please wait');
    final dateModel = DateModel(
      timestamp: Timestamp.fromDate(DateTime.now()),
      day: DateTime.now().day,
      month: DateTime.now().month,
      year: DateTime.now().year,
    );

    final address = AddressModel(
      addressLine1: addressLine1Controller.text,
      addressLine2: addressLine2Controller.text,
      zipcode: zipCodeController.text,
      city: city!,
    );
    userProvider.userModel!.addressModel = address;
    final order = OrderModel(
      orderId: generateOrderId,
      userModel: userProvider.userModel!,
      deliveryAddress: address,
      orderDate: dateModel,
      orderStatus: OrderStatus.pending,
      paymentMethod: paymentMethodGroupValue,
      productDetails: cartProvider.cartList,
      discount: orderProvider.orderConstantModel.discount,
      VAT: orderProvider.orderConstantModel.vat,
      deliveryCharge: orderProvider.orderConstantModel.deliveryCharge,
      grandTotal: orderProvider.getGrandTotal(cartProvider.getCartSubTotal()),
    );

    try {
      await orderProvider.saveOrder(order);
      await cartProvider.clearCart();
      EasyLoading.dismiss();
      Navigator.pushNamedAndRemoveUntil(context, OrderSuccessfulPage.routeName, ModalRoute.withName(ViewProductPage.routeName));

    } catch (error) {
      EasyLoading.dismiss();
      print(error.toString());
      rethrow;
    }
  }
}

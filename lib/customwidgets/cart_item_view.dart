import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';

class CartItemView extends StatelessWidget {
  final CartModel cartModel;
  final CartProvider provider;

  const CartItemView(
      {Key? key, required this.cartModel, required this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: CachedNetworkImage(
              width: 70,
              height: 70,
              imageUrl: cartModel.productModel.thumbnailImage.downloadUrl,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            title: Text(cartModel.productModel.productName),
            subtitle: Text('Unit Price: $currencySymbol${cartModel.productModel.calculatePriceAfterDiscount()}'),
            trailing: IconButton(
              onPressed: () {
                provider.removeFromCart(cartModel.productModel.productId!);
              },
              icon: const Icon(Icons.delete),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  provider.decreaseQuantity(cartModel);
                },
                icon: const Icon(
                  Icons.remove_circle,
                  size: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${cartModel.quantity}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () {
                  provider.increaseQuantity(cartModel);
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 30,
                ),
              ),
              const Spacer(),
              Text(
                '$currencySymbol${provider.priceWithQuantity(cartModel)}',
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
        ],
      ),
    ));
  }
}

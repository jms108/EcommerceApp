import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:ecommerce_app/model/product.dart';
//import 'package:ecommerce_app/product_details.dart';
import 'package:ecoomerceapp/model/product.dart';
import 'package:ecoomerceapp/product_details.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart' as http;
import 'api_service/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Product>> getProducts() async {
    List<Product> products = [];

    try {
      final url = Uri.parse(Api.getProductsUrl);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        for (var eachProduct in responseData as List) {
          products.add(Product.fromJson(eachProduct));
        }
      } else {
        Fluttertoast.showToast(msg: "Error fetching products");
      }
    } catch (errorMsg) {
      Fluttertoast.showToast(msg: errorMsg.toString());
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 96, 97, 97),
      ),
      body: FutureBuilder(
        future: getProducts(),
        builder: (context, AsyncSnapshot<List<Product>> dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dataSnapShot.hasError || dataSnapShot.data == null) {
            return const Center(child: Text("No Products Found!"));
          }

          if (dataSnapShot.data!.isEmpty) {
            return const Center(child: Text("No Products Found!"));
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              itemCount: dataSnapShot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.90,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemBuilder: (context, index) {
                Product eachProduct = dataSnapShot.data![index];
                return GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(ProductDetails(productInfo: eachProduct));
                        },
                        child: Card(
                          elevation: 2,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                child: Hero(
                                  tag: eachProduct.image!,
                                  child: CachedNetworkImage(
                                    imageUrl: eachProduct.image ?? '',
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Text(
                                eachProduct.title ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text("Tk ${eachProduct.price ?? '0'}"),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(30),
                                  backgroundColor:
                                      Color.fromARGB(255, 110, 110, 111),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  "Add To Cart",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

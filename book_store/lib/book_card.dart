import 'dart:convert';
import 'package:book_store/bookhome.dart';
import 'package:book_store/details_page.dart';
import 'package:book_store/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;

import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final List<Book> downloadedBooks;

  const BookCard(this.book, {super.key, required this.downloadedBooks});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  void initState() {
    super.initState();
    getPaymentInit();
  }

  String environment = 'SANDBOX';
  String appId = '';
  String package = 'com.example.phonpe_payment';
  String merchantId = 'PGTESTPAYUAT86';
  bool enableLogging = true;
  String checksum = '';
  String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  String saltIndex = "1";
  String callbackUrl = 'https://webhook.site/callback-url';
  String body = '';
  Object? result;
  double selectedAmount = 0.0;
  String apiEndPoint = "/pg/v1/pay";
  TextEditingController amount = TextEditingController();
  Future<void> startBookPurchase(
      {int? bookId,
      double? price,
      String? bookName,
      String? bookAuthor,
      String? bookDesc,
      String? bookImage}) async {
    try {
      // if (amount.text.isEmpty) {
      //   showMessage("Invalid book price", false);
      //   return;
      // }

      // double enteredAmount = price ?? 0.0;
      // if (enteredAmount <= 0) {
      //   showMessage("Invalid book price", false);
      //   return;
      // }

      //setLoading(true);
      body = await getSum(amt: price.toString());

      PhonePePaymentSdk.startTransaction(
        body,
        callbackUrl,
        checksum,
        package,
      ).then((response) async {
        // setLoading(false);
        setState(() {
          if (response != null) {
            if (response['status'] == 'SUCCESS') {
              // Store the purchased book data
              downloadednewBooks.add(DownloadBook(
                author: bookAuthor,
                description: bookDesc,
                imageUrl: bookImage,
                title: bookName,
                id: bookId,
              ));
              dev.log(
                  'downloaded books lenght is ${downloadednewBooks.length}');
              // fetchTotalBonusOfWhoReferedMe();
              result = 'Purchase Successful - Amount: ₹${amount.text}';
              showMessage('Purchase Successful! Amount: ₹${amount.text}', true);
              amount.clear();
            } else {
              result = 'Transaction Failed';
              showMessage(
                  'Transaction Failed: ${response['error'] ?? "Unknown error"}',
                  false);
            }
          } else {
            result = "Transaction Incomplete";
            showMessage('Transaction Incomplete', false);
          }
        });

        //  update(['profile']);
      }).catchError((error) {
        handleError(error);
      });
    } catch (e) {
      handleError(e);
    }
  }

  Future<String> getSum({String? amt}) async {
    String merchantTransactionId =
        DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now().toUtc());
    selectedAmount = double.tryParse(amt ?? "0.00") ?? 0.0;

    int amountInPaise = (selectedAmount * 100).round();
    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": merchantTransactionId,
      "merchantUserId": "MUID123",
      "amount": amountInPaise,
      "redirectUrl": "https://webhook.site/redirect-url",
      "redirectMode": "REDIRECT",
      "callbackUrl": callbackUrl,
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };

    String jsonRequest = jsonEncode(requestData);
    dev.log("Request Data JSON: $jsonRequest");
    //storeTransactionData(requestData, selectedAmount);
    dev.log("Request Data JSON: $jsonRequest");
    String base64 = base64Encode(utf8.encode(jsonRequest));
    dev.log("Request Data Base64: $base64");

    String dataToHash = base64 + apiEndPoint + saltKey;
    dev.log("Data to Hash for Checksum: $dataToHash");

    var bytes = utf8.encode(dataToHash);
    var digest = sha256.convert(bytes);
    checksum = "${digest.toString()}###$saltIndex";
    dev.log("Generated Checksum: $checksum");

    return base64.toString();
  }

  Future<void> getPaymentInit() async {
    try {
      PhonePePaymentSdk.init(
        environment,
        appId,
        merchantId,
        enableLogging,
      ).then((val) {
        result = 'PhonePe SDK Initialized - $val';
        dev.log("Status of PhonePe SDK Initialization: $result");
        //  update(['profile']);
      }).catchError((error) {
        dev.log("Initialization Error: $error");
        handleError(error);
      });
    } catch (e) {
      dev.log("Error in getPaymentInit: $e");
      handleError(e);
    }
  }

  void handleError(error) {
    //setLoading(false);
    //  dev.log("Error: $error");
    result = error.toString();
    showMessage('Error: ${error.toString()}', false);
    // update(['profile']);
  }

  void showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
    // ScaffoldMessenger.snackbar(
    //   isSuccess ? 'Success' : 'Error',
    //   message,
    //   snackPosition: SnackPosition.TOP,
    //   backgroundColor: isSuccess ? Colors.green : Colors.red,
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 3),
    //   margin: const EdgeInsets.all(10),
    // );
  }

  String _getShortenedTitle(String title) {
    List<String> words = title.split(' ');
    if (words.length > 2) {
      return '${words[0]} ${words[1]}...';
    }
    return title;
  }

  void _navigateToDetailsPage(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(
          title: book.title,
          authors: book.authors,
          description: book.description?.isNotEmpty == true
              ? book.description!
              : 'No description available.',
          imageUrl: book.imageUrl ?? '',
        ),
      ),
    );
  }

  Future<void> _downloadBook(BuildContext context, Book book) async {
    final dbHelper = DBHelper.instance;

    // Save the book to the SQLite database
    await dbHelper.insertBook(book);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${book.title} has been downloaded!'),
        backgroundColor: Colors.green,
      ),
    );

    // Fetch the updated list of downloaded books
    final downloadedBooks = await dbHelper.fetchBooks();

    // Navigate to the DownloadedBooksScreen with the updated list
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => DownloadedBooksScreen(
    //       downloadedBooks: downloadedBooks,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Image Section
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: widget.book.imageUrl != null &&
                      widget.book.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.book.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
            ),
          ),

          // Book Details Section
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getShortenedTitle(widget.book.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 4.0),

                Text(
                  widget.book.authors.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Price Section
                if (widget.book.discountedPrice < widget.book.price) ...[
                  Text(
                    'Price: \$${widget.book.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.grey[800],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    'Discounted: \$${widget.book.discountedPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.green[700],
                    ),
                  ),
                ] else ...[
                  Text(
                    'Price: \$${widget.book.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
                const SizedBox(height: 8.0),

                // Buttons Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Buy Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          dev.log(
                              'book prive is ${widget.book.discountedPrice}');
                          startBookPurchase(
                              bookId: widget.book.id,
                              bookAuthor: widget.book.authors.join(', '),
                              bookDesc: widget.book.description,
                              bookImage: widget.book.imageUrl,
                              bookName: widget.book.title,
                              price: widget.book.discountedPrice);
                          dev.log(
                              'downloaded books lenght is ${downloadednewBooks.length}');
                          //    await _downloadBook(context, widget.book);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5.0),

                    // Read Button
                    ElevatedButton(
                      onPressed: () {
                        _navigateToDetailsPage(context, widget.book);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Read',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

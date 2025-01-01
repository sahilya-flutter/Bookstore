// import 'dart:typed_data';
// import 'package:book_store/bookscreen/pdfviewscreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

// class MarathiBookScreen extends StatefulWidget {
//   const MarathiBookScreen({Key? key}) : super(key: key);

//   @override
//   State<MarathiBookScreen> createState() => _MarathiBookScreenState();
// }

// class _MarathiBookScreenState extends State<MarathiBookScreen> {
//   final FlutterTts _flutterTts = FlutterTts();
//   bool _isSpeaking = false;
//   bool _isLoading = false;
//   String? _currentSpeakingBook;

//   // Define color scheme
//   static const Color primaryColor = Color(0xFF1E88E5); // Blue
//   static const Color secondaryColor = Color(0xFF43A047); // Green
//   static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
//   static const Color cardColor = Colors.white;
//   static const Color textColor = Color(0xFF212121); // Dark Grey
//   static const Color authorTextColor = Color(0xFF757575); // Medium Grey

//   final List<Map<String, String>> books = [
//     {
//       "title": "छावा",
//       "author": "शिवाजी सावंत",
//       "image": "assets/images/chava.jpeg",
//       "pdf": "assets/pdf/chava.pdf",
//     },
//     {
//       "title": "संत तुकाराम",
//       "author": "संत तुकाराम",
//       "image": "assets/images/Sant_Tukaram.jpg",
//       "pdf": "assets/pdf/jagavegali.pdf",
//     },
//     {
//       "title": "ज्ञानेश्वर माऊली",
//       "author": "संत ज्ञानेश्वर माऊली",
//       "image": "assets/images/Sant_Dnyaneshwar.jpg",
//       "pdf": "assets/pdf/dnyaneshwari.pdf",
//     },
//     {
//       "title": "वृक्ष मंदिर",
//       "author": "अनिल अनंत वाकणकर",
//       "image": "assets/images/vrukshMandir marathi.jpg",
//       "pdf": "assets/pdf/vrukshmandir_anil_wakankar.pdf",
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeTts();
//   }

//   @override
//   void dispose() {
//     _flutterTts.stop();
//     super.dispose();
//   }

//   Future<void> _initializeTts() async {
//     await _flutterTts.setLanguage("mr-IN");
//     await _flutterTts.setSpeechRate(0.5);
//     await _flutterTts.setVolume(1.0);
//     await _flutterTts.setPitch(1.0);

//     _flutterTts.setCompletionHandler(() {
//       setState(() {
//         _isSpeaking = false;
//         _currentSpeakingBook = null;
//       });
//     });
//   }

//   void _navigateToPdfViewer(String pdfPath, String title) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PDFViewerScreen(
//           pdfPath: pdfPath,
//           bookTitle: title,
//         ),
//       ),
//     );
//   }

//   Future<void> _speakPDF(String pdfPath, String bookTitle) async {
//     try {
//       if (_isSpeaking && _currentSpeakingBook == bookTitle) {
//         await _flutterTts.stop();
//         setState(() {
//           _isSpeaking = false;
//           _currentSpeakingBook = null;
//         });
//         return;
//       }

//       if (_isSpeaking) {
//         await _flutterTts.stop();
//       }

//       setState(() {
//         _isLoading = true;
//       });

//       final String extractedText = await _extractTextFromPdf(pdfPath);

//       if (!mounted) return;

//       if (extractedText.isNotEmpty) {
//         setState(() {
//           _isSpeaking = true;
//           _currentSpeakingBook = bookTitle;
//           _isLoading = false;
//         });

//         String cleanedText = extractedText.replaceAll(RegExp(r'[^\w\s]'), '');

//         const int maxChunkSize = 1000;
//         List<String> chunks = [];
//         List<String> sentences = cleanedText.split(RegExp(r'[।\n]'));
//         String currentChunk = '';

//         for (String sentence in sentences) {
//           if ((currentChunk + sentence).length > maxChunkSize) {
//             if (currentChunk.isNotEmpty) {
//               chunks.add(currentChunk);
//             }
//             currentChunk = sentence;
//           } else {
//             currentChunk += sentence;
//           }
//         }

//         if (currentChunk.isNotEmpty) {
//           chunks.add(currentChunk);
//         }

//         for (String chunk in chunks) {
//           if (!_isSpeaking) break;
//           await _flutterTts.speak(chunk.trim());
//           await Future.delayed(Duration(milliseconds: chunk.length * 50));
//         }
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('पीडीएफ मध्ये मजकूर आढळला नाही.')),
//           );
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _isSpeaking = false;
//         _currentSpeakingBook = null;
//         _isLoading = false;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('पीडीएफ वाचण्यात त्रुटी: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<String> _extractTextFromPdf(String pdfPath) async {
//     try {
//       final ByteData data = await DefaultAssetBundle.of(context).load(pdfPath);
//       final Uint8List bytes = data.buffer.asUint8List();

//       final PdfDocument document = PdfDocument(inputBytes: bytes);
//       String extractedText = '';

//       for (int i = 0; i < document.pages.count; i++) {
//         PdfTextExtractor extractor = PdfTextExtractor(document);
//         String pageText = extractor.extractText(startPageIndex: i);
//         extractedText += pageText + '\n';
//       }

//       document.dispose();
//       return extractedText;
//     } catch (e) {
//       print("Error extracting text from PDF: $e");
//       return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen width to calculate responsive values
//     final screenWidth = MediaQuery.of(context).size.width;
//     final crossAxisCount = screenWidth > 600 ? 3 : 2;
//     final padding = screenWidth > 600 ? 16.0 : 0.0;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'मराठी पुस्तक',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: primaryColor,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(padding),
//         child: GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             childAspectRatio: 0.55,
//             crossAxisSpacing: padding,
//             mainAxisSpacing: padding,
//           ),
//           itemCount: books.length,
//           itemBuilder: (context, index) {
//             final book = books[index];
//             final bool isCurrentlyPlaying =
//                 _currentSpeakingBook == book['title'];
//             final bool isCurrentLoading =
//                 _isLoading && _currentSpeakingBook == book['title'];

//             return Card(
//               color: cardColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 4,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(12),
//                       ),
//                       child: Image.asset(
//                         book['image']!,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             book['title']!,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: textColor,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'लेखक: ${book['author']}',
//                             style: const TextStyle(
//                               color: authorTextColor,
//                               fontSize: 14,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const Spacer(),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     if (book['pdf'] != null) {
//                                       _navigateToPdfViewer(
//                                           book['pdf']!, book['title']!);
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: primaryColor,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 4),
//                                     minimumSize: const Size(0, 36),
//                                   ),
//                                   child: const Text(
//                                     'वाचा',
//                                     style: TextStyle(fontSize: 13),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: ElevatedButton.icon(
//                                   onPressed: isCurrentLoading
//                                       ? null
//                                       : () {
//                                           if (book['pdf'] != null) {
//                                             _speakPDF(
//                                                 book['pdf']!, book['title']!);
//                                           }
//                                         },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: secondaryColor,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 4),
//                                     minimumSize: const Size(0, 36),
//                                   ),
//                                   icon: SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: _isLoading && isCurrentlyPlaying
//                                         ? const CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           )
//                                         : Icon(
//                                             isCurrentlyPlaying
//                                                 ? Icons.stop
//                                                 : Icons.volume_up,
//                                             color: Colors.white,
//                                             size: 18,
//                                           ),
//                                   ),
//                                   label: Text(
//                                     isCurrentlyPlaying ? 'थांबवा' : 'ऐका',
//                                     style: const TextStyle(fontSize: 13),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

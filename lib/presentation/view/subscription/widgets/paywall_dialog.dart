// // Paywall Dialog Widget
// import 'package:adapty_flutter/adapty_flutter.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
// import 'package:mind_flow/presentation/viewmodel/subscription/paywall_provider.dart';
// import 'package:provider/provider.dart';

// class PaywallDialog extends StatefulWidget {
//   final String placementId;
//   final String title;
//   final List<String> features;
//   final Future<void> Function() onPurchase;
//   final int? creditAmount;

//   const PaywallDialog({super.key,
//     required this.placementId,
//     required this.title,
//     required this.features,
//     required this.onPurchase,
//     this.creditAmount,
//   });

//   @override
//   State<PaywallDialog> createState() => _PaywallDialogState();
// }

// class _PaywallDialogState extends State<PaywallDialog> {
//   @override
//   void initState() {
//     super.initState();
//     debugPrint('🎪 PaywallDialog initState called');
//     debugPrint('   Placement ID: ${widget.placementId}');
//     debugPrint('   Title: ${widget.title}');
//     debugPrint('   Credit Amount: ${widget.creditAmount}');
    
//     // Initialize provider after first frame to have context ready
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       debugPrint('🔄 Initializing PaywallProvider...');
//       final provider = context.read<PaywallProvider>();
//       provider.initialize(placementId: widget.placementId);
//     });
//   }
  
//   AdaptyPaywallProduct? _getProductForCreditAmount(List<AdaptyPaywallProduct> products) {
//     if (widget.creditAmount == null || products.isEmpty) {
//       return products.isNotEmpty ? products.first : null;
//     }
//     final productId = 'mind_flow_credits_${widget.creditAmount}';
//     try {
//       return products.firstWhere(
//         (product) => product.vendorProductId == productId,
//         orElse: () => products.first,
//       );
//     } catch (e) {
//       debugPrint('Product not found for credit amount: ${widget.creditAmount}');
//       return products.isNotEmpty ? products.first : null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         constraints: BoxConstraints(maxWidth: context.dynamicWidth(0.9)),
//         decoration: BoxDecoration(
//           color: const Color(0xFF0A0A0A),
//           borderRadius: BorderRadius.circular(context.dynamicWidth(0.05)),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//         child: ChangeNotifierProvider(
//           create: (_) => PaywallProvider(),
//           child: Builder(
//             builder: (context) {
//               final provider = context.watch<PaywallProvider>();
//               debugPrint('🔄 Builder rebuild triggered');
//               debugPrint('   Provider products length: ${provider.products.length}');
//               debugPrint('   Provider isLoading: ${provider.isLoading}');
//               debugPrint('   Provider errorMessage: ${provider.errorMessage}');
              
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                 // Modern Close button
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: Padding(
//                     padding: EdgeInsets.all(context.dynamicWidth(0.04)),
//                     child: GestureDetector(
//                       onTap: () => Navigator.of(context).pop(),
//                       child: Container(
//                         width: context.dynamicWidth(0.08),
//                         height: context.dynamicWidth(0.08),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(context.dynamicWidth(0.02)),
//                         ),
//                         child: Icon(
//                           Icons.close_rounded,
//                           color: Colors.white.withOpacity(0.8),
//                           size: context.dynamicHeight(0.02),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 if (provider.isLoading)
//                   Padding(
//                     padding: EdgeInsets.all(context.dynamicWidth(0.1)),
//                     child: const CircularProgressIndicator(color: Colors.white),
//                   )
//                 else if (provider.errorMessage != null)
//                   Padding(
//                     padding: EdgeInsets.all(context.dynamicWidth(0.1)),
//                     child: Column(
//                       children: [
//                         Icon(
//                           Icons.error_outline_rounded,
//                           size: context.dynamicHeight(0.06),
//                           color: Colors.white,
//                         ),
//                         SizedBox(height: context.dynamicHeight(0.02)),
//                         Text(
//                           provider.errorMessage!,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: context.dynamicHeight(0.018),
//                           ),
//                         ),
//                         SizedBox(height: context.dynamicHeight(0.02)),
//                         ElevatedButton(
//                           onPressed: () => provider.initialize(placementId: widget.placementId),
//                           child: Text(
//                             'Retry',
//                             style: TextStyle(
//                               fontSize: context.dynamicHeight(0.016),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 else
//                   Padding(
//                     padding: EdgeInsets.all(context.dynamicWidth(0.06)),
//                     child: Column(
//                       children: [
//                         // Modern Icon
//                         Container(
//                           width: context.dynamicWidth(0.2),
//                           height: context.dynamicWidth(0.2),
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                             ),
//                           ),
//                           child: Icon(
//                             Icons.auto_awesome_rounded,
//                             size: context.dynamicHeight(0.05),
//                             color: Colors.white,
//                           ),
//                         ),

//                         SizedBox(height: context.dynamicHeight(0.03)),

//                         // Modern Title
//                         Text(
//                           widget.title,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: context.dynamicHeight(0.032),
//                             fontWeight: FontWeight.w700,
//                             height: 1.2,
//                             letterSpacing: -1,
//                           ),
//                         ),

//                         SizedBox(height: context.dynamicHeight(0.03)),

//                         // Modern Features
//                         ...widget.features.map((feature) => Padding(
//                           padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.008)),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.check_circle_rounded,
//                                 color: Colors.white,
//                                 size: context.dynamicHeight(0.022),
//                               ),
//                               SizedBox(width: context.dynamicWidth(0.03)),
//                               Expanded(
//                                 child: Text(
//                                   feature,
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.9),
//                                     fontSize: context.dynamicHeight(0.016),
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )),

//                         SizedBox(height: context.dynamicHeight(0.03)),

//                         // Modern Price
//                         if (provider.products.isNotEmpty) ...[  
//                           Builder(
//                             builder: (context) {
//                               final product = _getProductForCreditAmount(provider.products);
//                               return Text(
//                                 product?.price.localizedString ?? '',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.9),
//                                   fontSize: context.dynamicHeight(0.018),
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               );
//                             },
//                           ),
//                         ],

//                         SizedBox(height: context.dynamicHeight(0.025)),

//                         // Modern Continue Button
//                         Builder(
//                           builder: (context) {
//                             final isDisabled = provider.isPurchasing || provider.products.isEmpty;
//                             debugPrint('🔍 Button state check:');
//                             debugPrint('   isPurchasing: ${provider.isPurchasing}');
//                             debugPrint('   products.isEmpty: ${provider.products.isEmpty}');
//                             debugPrint('   isDisabled: $isDisabled');
                            
//                             return GestureDetector(
//                               onTap: () {
//                                 debugPrint('🖱️ Continue button tapped!');
//                                 debugPrint('   isPurchasing: ${provider.isPurchasing}');
//                                 debugPrint('   products.isEmpty: ${provider.products.isEmpty}');
//                                 debugPrint('   products.length: ${provider.products.length}');
                                
//                                 final product = _getProductForCreditAmount(provider.products);
//                                 debugPrint('   Selected product: ${product?.vendorProductId}');
                                
//                                 if (product != null) {
//                                   debugPrint('🚀 Starting purchase process...');
//                                   provider.purchase(
//                                     context: context,
//                                     product: product,
//                                     onSuccess: () async {
//                                       debugPrint('✅ Purchase successful, calling onPurchase...');
//                                       await widget.onPurchase();
//                                       if (mounted) {
//                                         debugPrint('🚪 Closing dialog...');
//                                         Navigator.of(context).pop();
//                                       }
//                                     },
//                                   );
//                                 } else {
//                                   debugPrint('❌ No product selected');
//                                 }
//                               },
//                               child: Container(
//                                 width: double.infinity,
//                                 height: context.dynamicHeight(0.06),
//                                 decoration: BoxDecoration(
//                                   gradient: isDisabled 
//                                       ? null 
//                                       : const LinearGradient(
//                                           colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                                           begin: Alignment.centerLeft,
//                                           end: Alignment.centerRight,
//                                         ),
//                                   color: isDisabled ? Colors.grey.withOpacity(0.3) : null,
//                                   borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
//                                 ),
//                                 child: Center(
//                                   child: provider.isPurchasing
//                                       ? SizedBox(
//                                           width: context.dynamicHeight(0.025),
//                                           height: context.dynamicHeight(0.025),
//                                           child: const CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             color: Colors.white,
//                                           ),
//                                         )
//                                       : Row(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               'continue'.tr(),
//                                               style: TextStyle(
//                                                 fontSize: context.dynamicHeight(0.018),
//                                                 fontWeight: FontWeight.w700,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                             SizedBox(width: context.dynamicWidth(0.02)),
//                                             Icon(
//                                               Icons.arrow_forward_rounded,
//                                               size: context.dynamicHeight(0.02),
//                                               color: Colors.white,
//                                             ),
//                                           ],
//                                         ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
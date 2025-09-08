import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/services/auth_service.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:mind_flow/core/utility/extension/sized_box_extension.dart';
import 'package:mind_flow/injection/injection.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_analysis_card.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_analysis_grid.dart';
import 'package:mind_flow/presentation/view/home/widgets/home_header.dart';
import 'package:mind_flow/presentation/view/home/widgets/popular_topics_widget.dart';
import 'package:mind_flow/presentation/viewmodel/navigation/navigation_provider.dart';
import 'package:mind_flow/presentation/viewmodel/subscription/subscription_provider.dart';
import 'package:mind_flow/presentation/widgets/show_exit_dialog.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  final authService = AuthService();
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _initializeUser();
  });
  }
  Future<void> _initializeUser() async {
    final userId = _firestoreService.currentUserId;
    if (userId != null) {
      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.loadUserData(userId);
      if (subscriptionProvider.userSubscription == null || subscriptionProvider.userCredits == null) {
        await subscriptionProvider.initializeUserWithFreemium(userId);
      }
      subscriptionProvider.startListening(userId);
    }
  }
  @override
  Widget build(BuildContext context) {
    final navigationController = context.read<NavigationProvider>();
    final analysisList = GetAnalysisList().getAnalysisList(context);
    return WillPopScope(
      onWillPop: () async {
        if (navigationController.currentIndex == 0) {
          bool? shouldExit = await showExitDialog(context);
          return shouldExit ?? false;
        }
        navigationController.goBack();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  context.dynamicHeight(0.01).height,
                  HomeHeader(authService: authService),
                  context.dynamicHeight(.024).height,
                  const PopularTopicsWidget(),
                  context.dynamicHeight(.02).height,
                  AnalysisGrid(analysisList: analysisList),
                  
                  
      
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/core/utility/extension/sized_box_extension.dart';
import 'package:mind_flow/presentation/view/auth/login/login_view.dart';

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({
    super.key, required this.title, required this.subTitle,
  });
  final String title;
  final String subTitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.dynamicHeight(0.03)),
          topRight: Radius.circular(context.dynamicHeight(0.03)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.dynamicHeight(0.03)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.dynamicWidth(0.12),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            context.dynamicHeight(0.03).height,              
            Container(
              padding: EdgeInsets.all(context.dynamicHeight(0.02)),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                color: Theme.of(context).colorScheme.primary,
                size: context.dynamicHeight(0.05),
              ),
            ),
            context.dynamicHeight(0.02).height,
            Text(
              title,
              style: TextStyle(
                fontSize: context.dynamicHeight(0.024),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            context.dynamicHeight(0.01).height,
            Text(
              subTitle,
              style: TextStyle(
                fontSize: context.dynamicHeight(0.018),
              ),
              textAlign: TextAlign.center,
            ),
            context.dynamicHeight(0.04).height,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  RouteHelper.push(context, const LoginView());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.018)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                  ),
                ),
                child: Text(
                  'login'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicHeight(0.02),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            context.dynamicHeight(0.02).height,
            
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'late_for_now'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: context.dynamicHeight(0.018),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.white,
      elevation: elevation,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null),
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.headlineSmall,
            )
          : null,
      actions: actions,
      bottom: elevation > 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColors.gray200,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56 + (elevation > 0 ? 1 : 0));
}

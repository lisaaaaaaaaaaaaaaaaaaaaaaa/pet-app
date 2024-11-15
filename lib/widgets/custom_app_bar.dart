import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final bool showLogo;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final bool showBorder;

  const CustomAppBar({
    Key? key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.showLogo = false,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.systemOverlayStyle,
    this.bottom,
    this.flexibleSpace,
    this.showBorder = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppTheme.backgroundColor;
    final effectiveForegroundColor =
        foregroundColor ?? AppTheme.textPrimaryColor;

    Widget? titleWidget;
    if (showLogo) {
      titleWidget = AppLogo(
        size: 32,
        color: effectiveForegroundColor,
        alignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
      );
    } else if (title != null) {
      titleWidget = Text(
        title!,
        style: TextStyle(
          color: effectiveForegroundColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return AppBar(
      title: titleWidget,
      centerTitle: centerTitle,
      leading: _buildLeading(context, effectiveForegroundColor),
      actions: actions,
      backgroundColor: effectiveBackgroundColor,
      elevation: elevation,
      systemOverlayStyle: systemOverlayStyle ??
          SystemUiOverlayStyle(
            statusBarColor: effectiveBackgroundColor,
            statusBarIconBrightness: ThemeData.estimateBrightnessForColor(
                    effectiveBackgroundColor) ==
                Brightness.light
                ? Brightness.dark
                : Brightness.light,
          ),
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: bottom!.preferredSize,
              child: Container(
                decoration: showBorder
                    ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                      )
                    : null,
                child: bottom!,
              ),
            )
          : showBorder
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    color: AppTheme.dividerColor,
                    height: 1,
                  ),
                )
              : null,
      flexibleSpace: flexibleSpace,
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) return leading;
    if (!showBackButton) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      color: foregroundColor,
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

class CustomSliverAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final bool showLogo;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;
  final bool snap;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final PreferredSizeWidget? bottom;
  final bool showBorder;

  const CustomSliverAppBar({
    Key? key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.showLogo = false,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.expandedHeight = 200.0,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.systemOverlayStyle,
    this.bottom,
    this.showBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppTheme.backgroundColor;
    final effectiveForegroundColor =
        foregroundColor ?? AppTheme.textPrimaryColor;

    Widget? titleWidget;
    if (showLogo) {
      titleWidget = AppLogo(
        size: 32,
        color: effectiveForegroundColor,
        alignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
      );
    } else if (title != null) {
      titleWidget = Text(
        title!,
        style: TextStyle(
          color: effectiveForegroundColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return SliverAppBar(
      title: titleWidget,
      centerTitle: centerTitle,
      leading: _buildLeading(context, effectiveForegroundColor),
      actions: actions,
      backgroundColor: effectiveBackgroundColor,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
      pinned: pinned,
      floating: floating,
      snap: snap,
      systemOverlayStyle: systemOverlayStyle ??
          SystemUiOverlayStyle(
            statusBarColor: effectiveBackgroundColor,
            statusBarIconBrightness: ThemeData.estimateBrightnessForColor(
                    effectiveBackgroundColor) ==
                Brightness.light
                ? Brightness.dark
                : Brightness.light,
          ),
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: bottom!.preferredSize,
              child: Container(
                decoration: showBorder
                    ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                      )
                    : null,
                child: bottom!,
              ),
            )
          : showBorder
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    color: AppTheme.dividerColor,
                    height: 1,
                  ),
                )
              : null,
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) return leading;
    if (!showBackButton) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      color: foregroundColor,
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
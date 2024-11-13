import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final VoidCallback? onTitleTap;

  const CustomAppBar({
    Key? key,
    this.title,
    this.actions,
    this.showLogo = false,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.systemOverlayStyle,
    this.onTitleTap,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? 100 : 56);

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    final bool showLeading = automaticallyImplyLeading && canPop;

    Widget? titleWidget;
    if (showLogo) {
      titleWidget = GestureDetector(
        onTap: onTitleTap,
        child: const AppLogo(
          size: 40,
          showText: false,
          useGradient: false,
        ),
      );
    } else if (title != null) {
      titleWidget = GestureDetector(
        onTap: onTitleTap,
        child: Text(
          title!,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foregroundColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      );
    }

    return AppBar(
      backgroundColor: backgroundColor ?? AppTheme.primaryGreen,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.light,
      leading: leading ??
          (showLeading
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title: titleWidget,
      actions: [
        if (actions != null) ...actions!,
      ],
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: bottom!,
            )
          : null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: backgroundColor == null
              ? AppTheme.primaryGradient
              : null,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }
}

// Specialized variants
class SearchAppBar extends CustomAppBar {
  SearchAppBar({
    Key? key,
    required ValueChanged<String> onSearch,
    VoidCallback? onClear,
    String hintText = 'Search...',
    List<Widget>? actions,
  }) : super(
          key: key,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: hintText,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
          ),
          actions: actions,
        );
}

class TransparentAppBar extends CustomAppBar {
  TransparentAppBar({
    Key? key,
    String? title,
    List<Widget>? actions,
  }) : super(
          key: key,
          title: title,
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryGreen,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          actions: actions,
        );
}

class CollapsibleAppBar extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? flexibleSpace;

  const CollapsibleAppBar({
    Key? key,
    required this.title,
    required this.child,
    this.actions,
    this.flexibleSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: flexibleSpace ??
                FlexibleSpaceBar(
                  title: Text(title),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                  ),
                ),
            actions: actions,
          ),
        ];
      },
      body: child,
    );
  }
}
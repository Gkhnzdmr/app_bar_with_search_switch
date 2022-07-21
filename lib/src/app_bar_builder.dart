// Copyright (c) 2022, Alexqwesa.
// All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'app_bar_with_search_switch.dart';
import 'clear_or_close_icon_buttons.dart';
import 'leading_back_button.dart';
import 'search_text_field.dart';

class AppBarBuilder extends StatefulWidget {
  const AppBarBuilder({
    required this.showClearButton,
    required this.onChange,
    required this.controller,
    required this.hasText,
    required this.isSearchMode,
    required this.textNotifier,
    required this.submitNotifier,
    Key? key,
  }) : super(key: key);

  final void Function(String value)? onChange;
  final bool showClearButton;
  final TextEditingController controller;
  final ValueNotifier<bool> hasText;
  final ValueNotifier<bool> isSearchMode;
  final ValueNotifier<String> textNotifier;
  final ValueNotifier<String> submitNotifier;

  @override
  State<AppBarBuilder> createState() => AppBarBuilderState();
}

class AppBarBuilderState extends State<AppBarBuilder> {
  bool hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.showClearButton) {
      widget.controller.addListener(onTextChanged);
      widget.textNotifier.addListener(onTextNotifierChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(onTextChanged);
    widget.textNotifier.removeListener(onTextNotifierChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(AppBarBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(onTextChanged);
      widget.controller.addListener(onTextChanged);
    }
    if (oldWidget.textNotifier != widget.textNotifier) {
      oldWidget.textNotifier.removeListener(onTextNotifierChanged);
      widget.textNotifier.addListener(onTextNotifierChanged);
    }
  }

  void onTextNotifierChanged() {
    final controller = widget.controller;
    final notifier = widget.textNotifier;
    if (controller.text != notifier.value) {
      controller.text = notifier.value;
    }
  }

  void onTextChanged() {
    final controller = widget.controller;
    if (controller.text.isNotEmpty != hasText) {
      hasText = controller.text.isNotEmpty;
      setState(() {
        widget.hasText.value = hasText;
      });
    }
    widget.textNotifier.value = controller.text;
    widget.onChange?.call(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppBarWithSearchSwitch.of(context)!.isSearchMode,
      child: AppBarWithSearchSwitch.of(context)!.appBarBuilder(context),
      builder: (context, _, defaultAppBarWidget) {
        final mainWidget = AppBarWithSearchSwitch.of(context)!;
        final theme = Theme.of(context);
        final buttonColor =
            mainWidget.keepAppBarColors ? null : theme.iconTheme.color;
        final isSearching =
            AppBarWithSearchSwitch.of(context)!.isSearchMode.value;

        return !isSearching
            ? defaultAppBarWidget!
            : AppBar(
                leading: mainWidget.leading != null
                    ? mainWidget.leading?.call(context)
                    : LeadingIconBackButton(buttonColor: buttonColor),
                title: mainWidget.title != null
                    ? mainWidget.title?.call(context)
                    : const SearchTextField(),
                backgroundColor:
                    mainWidget.keepAppBarColors ? null : theme.canvasColor,
                // backgroundColor: mainWidget.backgroundColor,

                automaticallyImplyLeading: mainWidget.automaticallyImplyLeading,
                flexibleSpace: mainWidget.flexibleSpace,
                bottom: mainWidget.bottom,
                elevation: mainWidget.elevation,
                scrolledUnderElevation: mainWidget.scrolledUnderElevation,
                shadowColor: mainWidget.shadowColor,
                surfaceTintColor: mainWidget.surfaceTintColor,
                shape: mainWidget.shape,
                foregroundColor: mainWidget.foregroundColor,
                iconTheme: mainWidget.iconTheme,
                actionsIconTheme: mainWidget.actionsIconTheme,
                primary: mainWidget.primary,
                centerTitle: mainWidget.centerTitle,
                excludeHeaderSemantics: mainWidget.excludeHeaderSemantics,
                titleSpacing: mainWidget.titleSpacing,
                toolbarOpacity: mainWidget.toolbarOpacity,
                bottomOpacity: mainWidget.bottomOpacity,
                toolbarHeight: mainWidget.toolbarHeight,
                leadingWidth: mainWidget.leadingWidth,
                toolbarTextStyle: mainWidget.toolbarTextStyle,
                titleTextStyle: mainWidget.titleTextStyle,
                systemOverlayStyle: mainWidget.systemOverlayStyle,
                actions: [
                  //
                  // > clear button
                  //
                  if (mainWidget.showClearButton &&
                      !mainWidget.closeOnClearTwice &&
                      hasText)
                    ClearIconButton(
                      mainWidget: mainWidget,
                      buttonColor: buttonColor,
                    ),
                  //
                  // > clear or close button
                  //
                  if (mainWidget.showClearButton &&
                      mainWidget.closeOnClearTwice)
                    ClearOrCloseIconButton(
                      mainWidget: mainWidget,
                      hasText: hasText,
                      buttonColor: buttonColor,
                    ),
                  //
                  // > other actions
                  //
                  if (mainWidget.actions != null) ...mainWidget.actions!
                ],
              );
      },
    );
  }
}

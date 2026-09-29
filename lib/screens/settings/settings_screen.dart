import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:product_catalog/config/api_config.dart';
import 'package:product_catalog/config/service_locator.dart';
import 'package:product_catalog/stores/theme_store.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dark_colors.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/theme/light_colors.dart';
import 'package:product_catalog/widgets/large_title_header.dart';
import 'package:product_catalog/widgets/settings_section.dart';

/// Appearance and app information.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({this.scrollToTop, super.key});

  /// Fires when the user re-taps this screen's tab.
  final Listenable? scrollToTop;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final PackageInfo _info = getIt<PackageInfo>();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.scrollToTop?.addListener(_scrollToTop);
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollToTop != widget.scrollToTop) {
      oldWidget.scrollToTop?.removeListener(_scrollToTop);
      widget.scrollToTop?.addListener(_scrollToTop);
    }
  }

  @override
  void dispose() {
    widget.scrollToTop?.removeListener(_scrollToTop);
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scroll.hasClients || _scroll.offset <= 0) return;
    unawaited(
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  String get _versionLabel => '${_info.version} (${_info.buildNumber})';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: colors.background,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          const LargeTitleHeader(title: 'Settings'),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              Dimens.screenPadding,
              Dimens.space8,
              Dimens.screenPadding,
              bottomInset + Dimens.space32,
            ),
            sliver: SliverList.list(
              children: [
                SettingsSection(
                  title: 'Appearance',
                  footer:
                      'System follows your device\'s light or dark setting.',
                  children: [
                    Observer(
                      builder: (_) => _ThemePicker(
                        selected: _themeStore.themeMode,
                        onSelected: _themeStore.setThemeMode,
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'About',
                  children: [
                    SettingsTile(
                      icon: Icons.info_rounded,
                      iconBackground: colors.primary,
                      title: 'Version',
                      value: _versionLabel,
                    ),
                    SettingsTile(
                      icon: Icons.cloud_rounded,
                      iconBackground: colors.success,
                      title: 'Data source',
                      value: Uri.parse(ApiConfig.baseUrl).host,
                    ),
                  ],
                ),
                const SizedBox(height: Dimens.space8),
                Text(
                  'Product Catalog · Built with Flutter',
                  textAlign: TextAlign.center,
                  style: AppText.labelSmall(color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three tappable previews: System, Light and Dark.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.selected, required this.onSelected});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.space16,
        Dimens.space16,
        Dimens.space16,
        Dimens.space12,
      ),
      child: Row(
        children: [
          for (final mode in ThemeMode.values) ...[
            if (mode != ThemeMode.values.first)
              const SizedBox(width: Dimens.space12),
            Expanded(
              child: _ThemeOption(
                mode: mode,
                selected: mode == selected,
                onTap: () {
                  if (mode != selected) HapticFeedback.selectionClick();
                  onSelected(mode);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  String get _label => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: '$_label appearance',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.radiusMedium + 3),
                border: Border.all(
                  color: selected ? colors.primary : colors.border,
                  width: 2,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 0.72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.radiusMedium - 2),
                  child: switch (mode) {
                    ThemeMode.light => const _MiniScreen(palette: lightColors),
                    ThemeMode.dark => const _MiniScreen(palette: darkColors),
                    ThemeMode.system => const Row(
                      children: [
                        Expanded(child: _MiniScreen(palette: lightColors)),
                        Expanded(child: _MiniScreen(palette: darkColors)),
                      ],
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(height: Dimens.space8),
            Text(
              _label,
              style: AppText.labelLarge(
                color: selected ? colors.text : colors.textSecondary,
              ),
            ),
            const SizedBox(height: Dimens.space4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(selected),
                size: 20,
                color: selected ? colors.primary : colors.borderSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tiny drawing of the product list in one palette.
class _MiniScreen extends StatelessWidget {
  const _MiniScreen({required this.palette});

  final AppColors palette;

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFactor, Color color, [double height = 5]) {
      return FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Dimens.radiusPill),
          ),
        ),
      );
    }

    Widget card() {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: palette.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: palette.surfaceHighlight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(0.9, palette.textSecondary, 3),
                  const SizedBox(height: 3),
                  bar(0.5, palette.primary, 3),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ColoredBox(
      color: palette.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(0.6, palette.text, 6),
            const SizedBox(height: 6),
            bar(1, palette.surfaceHighlight, 8),
            const SizedBox(height: 6),
            card(),
            const SizedBox(height: 4),
            card(),
          ],
        ),
      ),
    );
  }
}

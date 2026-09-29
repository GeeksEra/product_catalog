import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';

/// An inset, grouped list section with a caption above and an optional note
/// below, like iOS Settings.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    this.footer,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = footer;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: Dimens.space16,
              bottom: Dimens.space8,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: AppText.labelSmall(
                  color: colors.textTertiary,
                ).copyWith(letterSpacing: 0.8),
              ),
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(Dimens.radiusLarge),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: Dimens.borderThin,
                      thickness: Dimens.borderThin,
                      indent: 56,
                      color: colors.border,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimens.space16,
                Dimens.space8,
                Dimens.space16,
                0,
              ),
              child: Text(
                note,
                style: AppText.bodySmall(color: colors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

/// A settings row: a colored icon tile, a title, and either a value or a
/// chevron when it can be tapped.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.iconBackground,
    required this.title,
    this.value,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trailing = value;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.space16,
            vertical: Dimens.space8,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 17, color: colors.buttonPrimaryText),
              ),
              const SizedBox(width: Dimens.space12),
              Expanded(
                child: Text(
                  title,
                  style: AppText.bodyLarge(color: colors.text),
                ),
              ),
              if (trailing != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    trailing,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMedium(color: colors.textTertiary),
                  ),
                ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.borderSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

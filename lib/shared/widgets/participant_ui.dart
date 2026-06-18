import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ParticipantPalette {
  static const Color pageBackground = AppColors.backgroundLight;
  static const Color surface = AppColors.glassPanel;
  static const Color border = Color(0x14000000);
  static const Color textPrimary = AppColors.textDark;
  static const Color textSecondary = AppColors.mutedText;
  static const Color primary = AppColors.persakaRed;
  static const Color secondary = AppColors.darkPurple;
  static const Color tertiary = AppColors.accentPurple;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color danger = AppColors.error;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, tertiary, secondary],
  );
}

class ParticipantPageScaffold extends StatelessWidget {
  const ParticipantPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    this.trailing,
    this.leading,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParticipantPalette.pageBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.persakaRed,
                    AppColors.accentPurple,
                    AppColors.darkPurple,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkPurple.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(height: 18),
                        ],
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.16),
                            ),
                          ),
                          child: Icon(icon, color: Colors.white),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 16),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            sliver: SliverList.list(children: children),
          ),
        ],
      ),
    );
  }
}

class ParticipantHeaderIconButton extends StatelessWidget {
  const ParticipantHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}

class ParticipantCard extends StatelessWidget {
  const ParticipantCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding,
      decoration: BoxDecoration(
        color: ParticipantPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ParticipantSectionHeader extends StatelessWidget {
  const ParticipantSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ParticipantPalette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: ParticipantPalette.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class ParticipantInfoChip extends StatelessWidget {
  const ParticipantInfoChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ParticipantMetricTile extends StatelessWidget {
  const ParticipantMetricTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.purpleTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkPurple.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantTimelineTile extends StatelessWidget {
  const ParticipantTimelineTile({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.dotColor,
  });

  final String time;
  final String title;
  final String subtitle;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              time,
              style: const TextStyle(
                color: ParticipantPalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ParticipantPalette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: ParticipantPalette.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParticipantBulletRow extends StatelessWidget {
  const ParticipantBulletRow({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ParticipantPalette.textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

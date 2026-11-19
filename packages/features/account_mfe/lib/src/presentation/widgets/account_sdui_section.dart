import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sdui_engine/sdui_engine.dart';

class AccountSduiSection extends StatelessWidget {
  const AccountSduiSection({
    super.key,
    required this.document,
    required this.onBenefitsRequested,
  });

  final SduiDocument document;
  final VoidCallback onBenefitsRequested;

  static final SduiRegistry _registry = createStandardSduiRegistry()
      .withComponents({
        'account_benefits_banner': _buildBenefitsBanner,
      })
      .withValidators({
        'account_benefits_banner': (node) {
          final title = node.props['title'];

          if (title is! String || title.trim().isEmpty) {
            return 'Título do benefício obrigatório';
          }

          if (title.length > 100) {
            return 'Título do benefício muito longo';
          }

          return null;
        },
      });

  @override
  Widget build(BuildContext context) {
    return SduiRenderer(
      document: document,
      registry: _registry,
      actionResolver: _resolveAction,
      fallback: const SizedBox.shrink(),
    );
  }

  VoidCallback? _resolveAction(SduiAction action) {
    return switch (action.type) {
      'show_benefit_details' => onBenefitsRequested,
      _ => null,
    };
  }

  static Widget _buildBenefitsBanner(
    BuildContext context,
    SduiNode node,
    List<Widget> children,
    VoidCallback? onAction,
  ) {
    final title = node.props['title'];
    final description = node.props['description'];
    final buttonLabel = node.props['buttonLabel'];

    if (title is! String || title.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.card_giftcard,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (description is String && description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.muted,
              ),
            ),
          ],
          if (onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: buttonLabel is String && buttonLabel.isNotEmpty
                  ? buttonLabel
                  : 'Saiba mais',
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

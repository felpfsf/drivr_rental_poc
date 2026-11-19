# Design System

Pacote compartilhado de apresentação do DrivR. Reúne tokens visuais, o tema
Material 3 e componentes genéricos reutilizáveis pelos MFEs. Não depende dos
domínios Catalog, Booking ou Account.

## Organização e API pública

O barrel [design_system.dart](lib/design_system.dart) exporta os arquivos
abaixo:

| Área | API | Implementação |
|---|---|---|
| Cores | `AppColors` | [app_colors.dart](lib/src/theme/app_colors.dart) |
| Espaçamentos | `AppSpacing` | [app_spacing.dart](lib/src/theme/app_spacing.dart) |
| Tema | `AppTheme.light` | [app_theme.dart](lib/src/theme/app_theme.dart) |
| Widget genérico | `AppButton` | [app_button.dart](lib/src/widgets/app_button.dart) |

### Tokens disponíveis

`AppColors` define `primary` (`#E50F3C`), `onPrimary`, `ink`, `canvas`,
`surface`, `muted`, `outline` e `success`. `AppSpacing` define `xs = 4`,
`sm = 8`, `md = 16`, `lg = 24` e `xl = 32` (valores em logical pixels).

`AppTheme.light` retorna um `ThemeData` Material 3 com `ColorScheme`, estilos
de texto, `AppBarTheme`, `FilledButtonTheme` e `NavigationBarTheme`. Há somente
esse tema exposto; não existe tema escuro no pacote atual.

## Uso em widgets

```dart
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

MaterialApp(
  theme: AppTheme.light,
  home: Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: AppButton(
      label: 'Continuar',
      onPressed: canContinue ? onContinue : null,
    ),
  ),
);
```

`AppButton` ocupa toda a largura disponível e usa `FilledButton`. Seu
`onPressed` é anulável: `null` desabilita o botão, conforme o comportamento do
widget Material subjacente.

## Componentes compartilhados e componentes de domínio

Um widget pertence ao Design System quando representa um padrão visual
genérico, reutilizável e sem conhecimento de uma feature. Componentes que
apresentam regras ou conteúdo específico — por exemplo, `CarCard` em Catalog
ou o banner de benefícios de Account — permanecem no MFE correspondente.
Assim, o pacote visual não passa a depender dos domínios.

Para adicionar um componente genérico seguindo o padrão atual:

1. Implemente o widget em `lib/src/widgets/`.
2. Use tokens e propriedades do tema em vez de duplicar valores de estilo.
3. Exporte o componente em `lib/design_system.dart`.
4. Adicione testes focados em `test/`.

Não importe código de `packages/features/` no Design System. O pacote usa
`material_ui` como biblioteca de widgets, alinhada ao restante do workspace.

## Testes

O arquivo [test/design_system_test.dart](test/design_system_test.dart) contém
atualmente apenas um teste placeholder; ainda não valida tokens, tema ou
`AppButton`.

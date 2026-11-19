# Account MFE

Feature de conta: login, cadastro demonstrativo, consulta de perfil e uma
seção SDUI de benefícios. A feature recebe repositories e callbacks de
apresentação; o Shell mantém a sessão e coordena as rotas.

## Estrutura e contratos

- [account_mfe.dart](lib/account_mfe.dart): barrel público.
- [auth_models.dart](lib/src/domain/auth_models.dart): `AccountUser` e
  `AuthSession`.
- [account_repository.dart](lib/src/data/account_repository.dart):
  `AccountRepository` e `HttpAccountRepository`.
- [account_sdui_repository.dart](lib/src/data/account_sdui_repository.dart):
  `AccountSduiRepository` e `HttpAccountSduiRepository`.
- `AccountPage`, `LoginPage`, `RegisterPage` e `ProfilePage` estão em
  `lib/src/presentation/`.
- [Seção SDUI](lib/src/presentation/widgets/account_sdui_section.dart) e
  [slot de perfil](lib/src/presentation/widgets/account_profile_sdui_slot.dart).

`AccountRepository` define login, cadastro e consulta do usuário atual:

```dart
Future<AuthSession> login({
  required String email,
  required String password,
});

Future<void> register({
  required String name,
  required String email,
  required String password,
});

Future<AccountUser> getAccount();
```

`AuthSession` contém `accessToken` e `AccountUser`; o usuário tem `id`, `name`
e `email`. `HttpAccountRepository` usa o `ApiClient` do Core:

| Método | Path | Resultado |
|---|---|---|
| `POST` | `/auth/login` | Converte token e usuário para `AuthSession` |
| `POST` | `/auth/register` | Envia nome, e-mail e senha; não interpreta resposta |
| `GET` | `/users/me` | Converte o perfil para `AccountUser` |

`AccountSduiRepository.getProfileLayout()` busca
`GET /account/profile-layout` e converte o objeto com `SduiParser`.

## Fluxos com o Shell

`AccountPage` solicita abertura do login por `onLoginRequested`. `LoginPage`
recebe um repository e, no sucesso, comunica a `AuthSession` ao Shell por
`onAuthenticated`. O Shell chama `SessionController.login`, tornando o token
disponível ao interceptor do `ApiClient`. Account não armazena nem persiste a
sessão.

Em `/account`, o Shell escolhe `ProfilePage` quando autenticado e
`AccountPage` caso contrário. O perfil chama `getAccount()` e oferece
`onLogout` como callback; o Shell limpa a sessão. A navegação para login,
cadastro e retorno ao fluxo de Booking também é controlada pelo Shell, não
por `GoRouter` dentro do MFE.

## Telas, erros e autenticação demonstrativa

- **Login:** valida presença de e-mail contendo `@` e senha não vazia; envia
  os campos ao repository, mostra loading e uma mensagem genérica em caso de
  erro.
- **Cadastro:** valida nome, formato básico de e-mail e senha com pelo menos
  seis caracteres. O sucesso da API só mostra uma confirmação demonstrativa;
  o fluxo não autentica automaticamente.
- **Perfil:** carrega os dados do usuário e o layout SDUI. Falha ao carregar o
  perfil mostra uma ação para sair. Falha no layout SDUI remove apenas a seção
  dinâmica.

Essas validações são de UI e não substituem validação no servidor. A
implementação atual não oferece armazenamento seguro, expiração/renovação de
token, logout remoto ou persistência do usuário. O ambiente Mockoon contém
credenciais de demonstração e o cadastro informa explicitamente que os dados
não são salvos.

## SDUI do perfil

`AccountSduiSection` registra `account_benefits_banner`, com `title`
obrigatório de até 100 caracteres e `description`/`buttonLabel` opcionais.
O botão só aparece quando a ação é reconhecida. A única ação aceita é
`show_benefit_details`, que chama `onBenefitsRequested` e abre um diálogo
estático de demonstração. Ações de outros domínios, como `open_car`, não são
executadas.

`SduiRenderer` aceita por padrão schemas 1 e 2. Um schema incompatível usa o
fallback vazio do Account; erro no fetch ou no parse também deixa a seção
vazia. Para os limites gerais do formato e registro de componentes, consulte
[SDUI Engine](../../sdui_engine/README.md).

## Testes

- [account_repository_test.dart](test/account_repository_test.dart): paths,
  bodies e conversões de login, cadastro e perfil.
- [account_sdui_test.dart](test/account_sdui_test.dart): renderização do
  componente e isolamento de ações não pertencentes ao domínio.

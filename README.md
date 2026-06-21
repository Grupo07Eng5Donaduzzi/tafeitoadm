# TáFeito Admin

Painel administrativo web do **TáFeito**, desenvolvido em Flutter Web para operação interna da plataforma.

O app centraliza rotinas de administração como consulta de contas, controle de pagamentos e auditoria de eventos. A interface consome a API do TáFeito e organiza as telas por módulo para manter o fluxo de suporte e moderação direto.

## Funcionalidades

- Login administrativo com token de acesso.
- Listagem e controle de contas de usuários.
- Acompanhamento de pagamentos, reembolsos e marcação de pagamento.
- Consulta de logs de auditoria.
- Layout web responsivo com navegação lateral administrativa.

## Tecnologias

- Flutter Web
- Dart
- Material Design
- `http` para chamadas REST
- `intl` para formatação
- `google_fonts` para tipografia

## Como executar

### Requisitos

- Flutter SDK instalado
- Dart compatível com o SDK do projeto
- Chrome ou outro navegador compatível com Flutter Web

Confira o ambiente local:

```bash
flutter doctor
```

Instale as dependências:

```bash
flutter pub get
```

Execute no Chrome:

```bash
flutter run -d chrome
```

Ou execute em uma porta específica:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5173
```

Acesse:

```text
http://127.0.0.1:5173
```

## Comandos úteis

Formatar o código:

```bash
dart format .
```

Analisar o projeto:

```bash
flutter analyze
```

Executar testes:

```bash
flutter test
```

Gerar build web:

```bash
flutter build web
```

## Padrão escolhido

O projeto usa uma organização **feature-first** com separação em camadas inspirada em MVVM e Repository Pattern.

```text
lib/
  main.dart
  src/
    app.dart
    core/
      network/
      result/
      session/
      theme/
      utils/
      widgets/
    features/
      auth/
      accounts/
      chats/
      payments/
      audit/
```

Cada feature segue a estrutura:

```text
data/
  *_remote_data_source.dart
  *_repository.dart
domain/
  *_models.dart
presentation/
  *_screen.dart
  *_view_model.dart
```

Principais decisões do padrão:

- `presentation`: telas e `ViewModel` com `ChangeNotifier`.
- `domain`: modelos usados pela regra de apresentação.
- `data`: repositories e data sources responsáveis pela comunicação externa.
- `core/network`: `ApiClient` central para requisições HTTP.
- `core/result`: tipo `Result<T>` para padronizar sucesso e erro.
- `core/session`: estado da sessão autenticada e seção selecionada.

## API utilizada

A aplicação consome uma API REST JSON.

```text
Base URL: https://api.tafeito.app
```

O cliente HTTP central fica em:

```text
lib/src/core/network/api_client.dart
```

A URL base é configurada na inicialização do app:

```text
lib/src/app.dart
```

### Autenticação

```text
POST /v1/auth/login
```

O login espera um retorno com `accessToken` e dados do usuário. Depois da autenticação, o token é enviado nas próximas requisições como:

```text
Authorization: Bearer <token>
```

### Endpoints administrativos

```text
GET   /v1/admin/users
PATCH /v1/admin/users/:id/deactivate
PATCH /v1/admin/users/:id/activate

GET   /v1/admin/payments
POST  /v1/admin/payments/:id/refund
POST  /v1/admin/payments/:id/mark-paid

GET   /v1/admin/audit
```

Os data sources que fazem essas chamadas ficam em:

```text
lib/src/features/*/data/*_remote_data_source.dart
```



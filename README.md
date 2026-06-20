# TáFeito Admin

Painel administrativo web do **TáFeito** feito em Flutter Web.

O projeto está com dados mockados por enquanto. A ideia é deixar o front pronto para depois conectar com a API real.

## Requisitos

- Flutter SDK
- Dart compatível com o projeto
- Chrome ou outro navegador para rodar o Flutter Web

Verifique o ambiente:

```bash
flutter doctor
```

## Instalação

```bash
flutter pub get
```

## Rodando localmente

```bash
flutter run -d chrome
```

Ou em uma porta específica:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5173
```

Acesse:

```text
http://127.0.0.1:5173
```

## Login mockado

Use:

```text
E-mail: admin@tafeito.com
Senha: admin123
```

Também funciona com qualquer e-mail válido e senha com pelo menos 4 caracteres.

## Comandos úteis

Formatar:

```bash
dart format .
```

Analisar:

```bash
flutter analyze
```

Testar:

```bash
flutter test
```

Build web:

```bash
flutter build web
```

## Estrutura principal

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
      dashboard/
      accounts/
      chats/
      payments/
      audit/
```

Cada feature segue mais ou menos este padrão:

```text
data/
  remote_data_source
  repository
domain/
  models
presentation/
  screen
  view_model
```

## Onde plugar o backend

Hoje os dados vêm dos arquivos `*_remote_data_source.dart`.

Para conectar a API real, comece por estes pontos:

```text
lib/src/core/network/api_client.dart
lib/src/features/*/data/*_remote_data_source.dart
```

O projeto já tem:

- `ApiClient` central
- `Result<T>` com sucesso/erro
- repositories por feature
- viewmodels com `ChangeNotifier`

## Endpoints esperados

```text
POST   /v1/admin/auth/login
GET    /v1/admin/dashboard

GET    /v1/admin/users
GET    /v1/admin/users/:id
PATCH  /v1/admin/users/:id
PATCH  /v1/admin/users/:id/suspend
PATCH  /v1/admin/users/:id/restore
DELETE /v1/admin/users/:id

GET    /v1/admin/chats
GET    /v1/admin/chats/:id/messages
PATCH  /v1/admin/chats/:id/review
PATCH  /v1/admin/chats/:id/flag

GET    /v1/admin/payments
GET    /v1/admin/payments/:id
POST   /v1/admin/payments/:id/refund
POST   /v1/admin/payments/:id/release
POST   /v1/admin/payments/:id/dispute
POST   /v1/admin/payments/:id/resolve

GET    /v1/admin/audit-logs
```


# Mapeamento para Construção da API (Koin 💰)

Este documento contém o levantamento detalhado de todas as entidades, enums e rotas necessárias para a construção da API do aplicativo **Koin**, baseado nos mocks e estrutura do frontend em Flutter.

---

## 1. Entidades e Modelos de Dados

Abaixo estão descritas as entidades com seus respectivos atributos e tipos de dados. Os tipos indicados são sugeridos para a API REST (JSON).

### A. Usuário (`User`)
Representa o usuário autenticado no sistema.

* **Campos:**
  * `id` (String / UUID): Identificador único do usuário. Ex: `"usr_lucas123"`.
  * `name` (String): Nome completo do usuário. Ex: `"Lucas Antunes"`.
  * `email` (String): E-mail do usuário (usado para login). Ex: `"lucas@koin.com"`.
  * `password` (String): Senha do usuário (na API deve ser armazenada como hash/criptografada).
  * `gender` (String / Enum): Gênero do usuário. Valores: `male`, `female`, `other`, `notSpecified`.
  * `creationDate` (DateTime / ISO 8601): Data de criação da conta.

### B. Conta Bancária (`BankAccount`)
Representa a conta financeira ativa do usuário. O app atualmente utiliza uma conta principal.

* **Campos:**
  * `id` (String / UUID): Identificador único da conta. Ex: `"acc_wallet_01"`.
  * `userId` (String / UUID): Referência ao `User.id` (Chave Estrangeira).
  * `name` (String): Nome da conta. Ex: `"Carteira Principal"`.
  * `balance` (Double / Decimal): Saldo atual da conta. Ex: `10300.00`.
  * `type` (String / Enum): Tipo de conta. Valores: `checking` (corrente), `savings` (poupança), `cash` (dinheiro em espécie), `creditCard` (cartão de crédito).
  * `currency` (String / Enum): Moeda da conta. Valores: `brl`, `usd`.

### C. Meta Financeira (`Goal`)
Representa os objetivos de economia financeira criados pelo usuário.

* **Campos:**
  * `id` (String / UUID): Identificador único da meta. Ex: `"goal_01"`.
  * `userId` (String / UUID): Referência ao `User.id` (Chave Estrangeira).
  * `bankAccountId` (String / UUID, opcional): Referência opcional à conta vinculada.
  * `name` (String): Título do objetivo. Ex: `"Viagem Japão (1 ano)"`.
  * `targetAmount` (Double / Decimal): Valor total a ser poupado. Ex: `8000.00`.
  * `currentAmount` (Double / Decimal): Valor poupado até o momento. Ex: `5200.00`.
  * `status` (String / Enum): Estado da meta. Valores: `inProgress`, `completed`, `cancelled`.
  * `deadlineDate` (DateTime / ISO 8601): Data limite para atingir a meta.

### D. Transação (`Transaction`)
Representa as movimentações de entrada e saída financeira do usuário.

* **Campos:**
  * `id` (String / UUID): Identificador único da transação. Ex: `"tx_01"`.
  * `bankAccountId` (String / UUID): Referência à conta que originou/recebeu o valor (`BankAccount.id`).
  * `destinationBankAccountId` (String / UUID, opcional): Referência à conta de destino em caso de transferência.
  * `type` (String / Enum): Tipo da transação. Valores: `income` (receita), `expense` (despesa), `transfer` (transferência).
  * `transactionCategoryId` (String / UUID, opcional): Referência à categoria de gastos (Alimentação, Transporte, Lazer, etc.).
  * `amount` (Double / Decimal): Valor da transação. Ex: `45.00`.
  * `description` (String): Descrição da transação. Ex: `"Almoço Executivo"`.
  * `transactionDate` (DateTime / ISO 8601): Data em que a transação ocorreu.
  * `creationDate` (DateTime / ISO 8601): Data em que a transação foi registrada.

---

## 2. Enums Utilizados

Os enums que definem as restrições de domínios nos campos são:

1. **`Gender`**
   * `male`
   * `female`
   * `other`
   * `notSpecified`

2. **`BankAccountType`**
   * `checking`
   * `savings`
   * `cash`
   * `creditCard`

3. **`Currency`**
   * `brl`
   * `usd`

4. **`TransactionType`**
   * `income`
   * `expense`
   * `transfer`

5. **`GoalStatus`**
   * `inProgress`
   * `completed`
   * `cancelled`

---

## 3. Mapeamento de Rotas da API

Para suprir as telas e fluxos existentes do aplicativo (Login, Dashboard, Transações, Nova Transação, Detalhes e Metas), a API deve disponibilizar as seguintes rotas e contratos de dados:

### Autenticação & Usuários
#### 1. `POST /api/auth/login`
* **Descrição:** Autentica o usuário com e-mail e senha.
* **Corpo da Requisição (JSON):**
  ```json
  {
    "email": "lucas@koin.com",
    "password": "hashed_password_here"
  }
  ```
* **Resposta de Sucesso (200 OK):**
  ```json
  {
    "token": "jwt_token_exemplo...",
    "user": {
      "id": "usr_lucas123",
      "name": "Lucas Antunes",
      "email": "lucas@koin.com",
      "gender": "male",
      "creationDate": "2026-05-06T20:14:42.000Z"
    }
  }
  ```

#### 2. `GET /api/users/me`
* **Descrição:** Recupera os dados do usuário autenticado no momento (via cabeçalho `Authorization: Bearer <token>`).
* **Resposta de Sucesso (200 OK):** Entidade `User` em formato JSON.

---

### Contas Bancárias
#### 3. `GET /api/accounts`
* **Descrição:** Lista as contas bancárias do usuário autenticado.
* **Resposta de Sucesso (200 OK):**
  ```json
  [
    {
      "id": "acc_wallet_01",
      "userId": "usr_lucas123",
      "name": "Carteira Principal",
      "balance": 10300.00,
      "type": "checking",
      "currency": "brl"
    }
  }
  ```

#### 4. `GET /api/accounts/primary`
* **Descrição:** Retorna a conta principal/padrão do usuário para exibição no Dashboard.
* **Resposta de Sucesso (200 OK):** Entidade `BankAccount` em formato JSON.

---

### Transações
#### 5. `GET /api/transactions`
* **Descrição:** Lista o histórico de transações do usuário. Suporta filtros que correspondem à barra de pesquisa e chips de filtro do aplicativo.
* **Parâmetros de Query (Opcionais):**
  * `search` (String): Filtra transações cuja descrição contenha a palavra chave.
  * `type` (String): Filtra por tipo (`income`, `expense`, `transfer`).
* **Resposta de Sucesso (200 OK):**
  ```json
  [
    {
      "id": "tx_01",
      "bankAccountId": "acc_wallet_01",
      "type": "expense",
      "amount": 45.00,
      "description": "Almoço Executivo",
      "transactionDate": "2026-06-05T20:14:42.000Z",
      "creationDate": "2026-06-05T20:14:42.000Z"
    },
    {
      "id": "tx_02",
      "bankAccountId": "acc_wallet_01",
      "type": "income",
      "amount": 20.00,
      "description": "Economia Diária Hábito",
      "transactionDate": "2026-06-05T20:14:42.000Z",
      "creationDate": "2026-06-05T20:14:42.000Z"
    }
  ]
  ```

#### 6. `GET /api/transactions/{id}`
* **Descrição:** Busca detalhes de uma transação específica.
* **Resposta de Sucesso (200 OK):** Entidade `Transaction` em formato JSON.

#### 7. `POST /api/transactions`
* **Descrição:** Registra uma nova transação.
* **Comportamento no Servidor:** O saldo da conta vinculada (`bankAccountId`) deve ser incrementado caso o tipo seja `income` (receita) ou decrementado caso o tipo seja `expense` (despesa).
* **Corpo da Requisição (JSON):**
  ```json
  {
    "bankAccountId": "acc_wallet_01",
    "type": "expense",
    "amount": 12.50,
    "description": "Café da Tarde"
  }
  ```
* **Resposta de Sucesso (201 Created):** Entidade `Transaction` criada, contendo o `id` gerado, `transactionDate` e `creationDate`.

---

### Metas (Goals)
#### 8. `GET /api/goals`
* **Descrição:** Lista todas as metas de poupança cadastradas para o usuário.
* **Resposta de Sucesso (200 OK):**
  ```json
  [
    {
      "id": "goal_01",
      "userId": "usr_lucas123",
      "name": "Viagem Japão (1 ano)",
      "targetAmount": 8000.00,
      "currentAmount": 5200.00,
      "status": "inProgress",
      "deadlineDate": "2027-06-05T20:14:42.000Z"
    }
  ]
  ```

#### 9. `POST /api/goals`
* **Descrição:** Cadastra uma nova meta financeira (ligado à ação do botão de adição na tela de Metas).
* **Corpo da Requisição (JSON):**
  ```json
  {
    "name": "Troca de Notebook",
    "targetAmount": 5000.00,
    "deadlineDate": "2026-12-31T23:59:59.000Z"
  }
  ```
* **Resposta de Sucesso (201 Created):** Entidade `Goal` criada, com `currentAmount` inicializado em `0.00` e `status` como `"inProgress"`.

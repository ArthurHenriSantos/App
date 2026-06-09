# Koin 💰 - Gestão Financeira Inteligente

O **Koin** é um aplicativo moderno de gestão financeira inteligente projetado para ajudar os usuários a entenderem e controlarem seus fluxos financeiros diários. Ele oferece uma interface mobile fluida e intuitiva, integrada com um backend ágil e seguro para cadastro de receitas, despesas, transferências e acompanhamento de metas financeiras.

---

## 🚀 Funcionalidades Principais (MVP)

*   **🔒 Autenticação Segura:** Cadastro e login de usuários com criptografia e autenticação JWT. Suporte nativo a fluxo OAuth2 com PKCE.
*   **📊 Dashboard Financeiro Visual:** Resumos visuais interativos do saldo atual, fluxo de entrada/saída de dinheiro e gráficos por categoria.
*   **💸 Gestão Dinâmica de Transações:** Registro ágil de receitas (*income*), despesas (*expense*) e transferências (*transfer*) entre contas.
*   **🏷️ Categorização Inteligente:** Classificação das movimentações financeiras para facilitar análises futuras do comportamento de consumo.
*   **🎯 Metas de Economia:** Criação de objetivos financeiros personalizados (ex. "Viagem Japão", "Reserva de Emergência") com barras de progresso que se atualizam automaticamente conforme novas transações são registradas.
*   **💾 Persistência de Estado:** Backend configurado com persistência local em arquivo JSON (`state_persistence.json`), mantendo seus dados salvos após reiniciar a aplicação.

---

## 🛠️ Tecnologias Utilizadas

### Frontend (Mobile/Web/Desktop)
*   **Framework:** [Flutter](https://flutter.dev/) (SDK `^3.10.8`)
*   **Linguagem:** Dart
*   **Gerenciamento de Rotas:** [GoRouter](https://pub.dev/packages/go_router)
*   **Comunicação API:** Biblioteca `http`
*   **Estilização:** Paleta moderna e harmoniosa baseada em Slate, Indigo e Cyan (Suporta modo Dark/Light).

### Backend (API RESTful)
*   **Framework:** [FastAPI](https://fastapi.tiangolo.com/) (Python)
*   **Servidor Web:** Uvicorn
*   **Segurança:** PyJWT para tokens de acesso, PKCE para fluxos OAuth2
*   **Banco de Dados:** Em memória com persistência estruturada em arquivo JSON local.

---

## 📁 Estrutura do Projeto

```text
Koin/
├── backend/                  # Código fonte da API RESTful (Python)
│   ├── app/                  # Módulos principais (main, schemas, state)
│   ├── requirements.txt      # Dependências Python
│   └── Dockerfile            # Configuração Docker do Backend
├── frontend/                 # Aplicativo Mobile/Web/Desktop (Flutter)
│   ├── lib/                  # Código fonte Dart
│   │   ├── core/             # Serviços globais (API), utilitários e tema
│   │   ├── features/         # Features organizadas (auth, finance, goal, etc.)
│   │   ├── models/           # Enums e modelos globais
│   │   ├── router/           # Configuração de rotas (GoRouter)
│   │   └── main.dart         # Inicialização do app
│   └── pubspec.yaml          # Dependências do Flutter
├── docs/                     # Documentação de apoio
│   ├── api_mapping.md        # Detalhamento de rotas e entidades
│   ├── proposta.md           # Proposta técnica do projeto
│   └── rodar_backend.md      # Instruções rápidas para Docker
└── README.md                 # Documento principal
```

---

## ⚙️ Pré-requisitos

Para rodar o projeto localmente, você precisará ter instalado em sua máquina:
*   [Git](https://git-scm.com/)
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão `>=3.10.8` recomendada)
*   [Python 3.11+](https://www.python.org/downloads/)
*   *[Opcional]* [Docker](https://www.docker.com/)

---

## 🏃 Como Executar o Projeto

Siga as instruções abaixo para colocar ambos os serviços em execução.

### 1. Inicializar o Backend (API)

Você pode rodar a API de duas maneiras: diretamente no Python ou via Docker.

#### Opção A: Execução Local com Python (Recomendada)
No terminal, navegue até a pasta `backend` e execute os comandos:

```bash
# 1. Entre no diretório do backend
cd backend

# 2. Crie um ambiente virtual (opcional, mas recomendado)
python -m venv venv

# 3. Ative o ambiente virtual
# No Windows (PowerShell):
.\venv\Scripts\Activate.ps1
# No Windows (CMD):
.\venv\Scripts\activate.bat
# No macOS/Linux:
source venv/bin/activate

# 4. Instale as dependências
pip install -r requirements.txt

# 5. Inicie o servidor FastAPI
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
A API estará disponível em: [http://localhost:8000](http://localhost:8000). A documentação interativa (Swagger) estará em: [http://localhost:8000/docs](http://localhost:8000/docs).

#### Opção B: Execução via Docker
Caso tenha o Docker instalado e queira rodar em container, execute na pasta `backend`:

```bash
# Construir a imagem Docker
docker build -t koin .

# Executar o container exposto na porta 8000
docker run -d -p 8000:8000 --name koin koin
```

---

### 2. Inicializar o Frontend (Flutter)

Com o backend ativo, configure e execute o aplicativo Flutter:

```bash
# 1. Navegue até o diretório do frontend
cd frontend

# 2. Obtenha as dependências do projeto
flutter pub get

# 3. Execute o aplicativo
flutter run
```

> 💡 **Nota sobre conexão com a API:**
> O aplicativo está configurado no arquivo `frontend/lib/core/services/api_service.dart` para redirecionar automaticamente as requisições:
> *   **Navegador Web / Emulador iOS / Desktop:** Conecta em `http://localhost:8000/api`
> *   **Emulador Android:** Conecta em `http://10.0.2.2:8000/api` (redirecionamento automático do Android Loopback).

---

## 🔑 Credenciais para Teste Rápido

Para testar o aplicativo sem criar uma nova conta, utilize as credenciais padrão pré-carregadas no banco de dados em memória:

*   **E-mail:** `lucas@koin.com`
*   **Senha:** `123456`

*(Você também pode se cadastrar livremente criando uma nova conta na tela de registro do app ou pela página de registro OAuth2).*

---

## 📖 Documentações Úteis

Para mais detalhes sobre as rotas e contratos da API ou wireframes, consulte os documentos na pasta `docs/`:
*   [Mapeamento de Rotas da API](docs/api_mapping.md) - Contratos JSON, tipos de parâmetros e retornos da API.
*   [Proposta Técnica do Projeto](docs/proposta.md) - Requisitos funcionais, cronograma de módulos e regras de negócios.

from fastapi import FastAPI, HTTPException, status, Query, Header
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional

from app.schemas import (
    UserLogin, UserRegister, UserUpdate, LoginResponse, UserResponse,
    BankAccount, BankAccountCreate, BankAccountUpdate,
    Transaction, TransactionCreate, TransactionUpdate, TransactionType,
    Goal, GoalCreate, GoalUpdate
)
from app.state import state

app = FastAPI(
    title="Koin API",
    description="API Completa para o gerenciador financeiro inteligente Koin (Salva em memória)",
    version="1.1.0"
)

# Configurando o middleware de CORS para permitir acesso do Flutter/Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especificar as origens permitidas
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- Endpoints de Autenticação & Usuários ---

@app.post("/api/auth/register", response_model=LoginResponse, status_code=status.HTTP_201_CREATED, tags=["Autenticação"])
def register(user_data: UserRegister):
    user = state.add_user(
        name=user_data.name,
        email=user_data.email,
        password=user_data.password,
        gender=user_data.gender
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="E-mail já cadastrado no sistema."
        )
    return LoginResponse(
        token=f"mock_jwt_token_for_{user.id}",
        user=UserResponse(
            id=user.id,
            name=user.name,
            email=user.email,
            gender=user.gender,
            creationDate=user.creationDate
        )
    )

@app.post("/api/auth/login", response_model=LoginResponse, tags=["Autenticação"])
def login(credentials: UserLogin):
    user = None
    for u in state.users.values():
        if u.email == credentials.email:
            user = u
            break
            
    if not user or credentials.password != user.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas. Para testar use: lucas@koin.com / 123456"
        )
            
    return LoginResponse(
        token=f"mock_jwt_token_for_{user.id}",
        user=UserResponse(
            id=user.id,
            name=user.name,
            email=user.email,
            gender=user.gender,
            creationDate=user.creationDate
        )
    )

@app.get("/api/users/me", response_model=UserResponse, tags=["Usuários"])
def get_me(authorization: Optional[str] = Header(None)):
    # Retorna o usuário logado padrão (Lucas) para fins de desenvolvimento/mock
    user = state.users.get("usr_lucas123")
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuário não encontrado"
        )
    return UserResponse(
        id=user.id,
        name=user.name,
        email=user.email,
        gender=user.gender,
        creationDate=user.creationDate
    )

@app.patch("/api/users/me", response_model=UserResponse, tags=["Usuários"])
def update_me(user_update: UserUpdate, authorization: Optional[str] = Header(None)):
    user = state.update_user(
        user_id="usr_lucas123",
        name=user_update.name,
        gender=user_update.gender
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuário não encontrado"
        )
    return UserResponse(
        id=user.id,
        name=user.name,
        email=user.email,
        gender=user.gender,
        creationDate=user.creationDate
    )


# --- Endpoints de Contas Bancárias ---

@app.get("/api/accounts", response_model=List[BankAccount], tags=["Contas Bancárias"])
def get_accounts():
    return list(state.accounts.values())

@app.get("/api/accounts/primary", response_model=BankAccount, tags=["Contas Bancárias"])
def get_primary_account():
    account = state.accounts.get("acc_wallet_01")
    if not account:
        # Se a conta principal foi excluída por teste, pega a primeira disponível
        if state.accounts:
            return list(state.accounts.values())[0]
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nenhuma conta bancária disponível"
        )
    return account

@app.get("/api/accounts/{id}", response_model=BankAccount, tags=["Contas Bancárias"])
def get_account_by_id(id: str):
    account = state.accounts.get(id)
    if not account:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conta não encontrada"
        )
    return account

@app.post("/api/accounts", response_model=BankAccount, status_code=status.HTTP_201_CREATED, tags=["Contas Bancárias"])
def create_account(account_data: BankAccountCreate):
    # Associa a conta ao usuário padrão
    account = state.add_bank_account(
        user_id="usr_lucas123",
        name=account_data.name,
        balance=account_data.balance,
        type_=account_data.type,
        currency=account_data.currency
    )
    return account

@app.patch("/api/accounts/{id}", response_model=BankAccount, tags=["Contas Bancárias"])
def update_account(id: str, account_data: BankAccountUpdate):
    account = state.update_bank_account(
        acc_id=id,
        name=account_data.name,
        type_=account_data.type,
        currency=account_data.currency
    )
    if not account:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Conta bancária '{id}' não encontrada"
        )
    return account

@app.delete("/api/accounts/{id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Contas Bancárias"])
def delete_account(id: str):
    success = state.delete_bank_account(id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Conta bancária '{id}' não encontrada"
        )
    return None


# --- Endpoints de Transações ---

@app.get("/api/transactions", response_model=List[Transaction], tags=["Transações"])
def get_transactions(
    search: Optional[str] = Query(None, description="Filtrar por descrição"),
    type: Optional[TransactionType] = Query(None, description="Filtrar por tipo (income, expense, transfer)")
):
    return state.get_filtered_transactions(search=search, type_=type)

@app.get("/api/transactions/{id}", response_model=Transaction, tags=["Transações"])
def get_transaction(id: str):
    tx = state.get_transaction_by_id(id)
    if not tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transação não encontrada"
        )
    return tx

@app.post("/api/transactions", response_model=Transaction, status_code=status.HTTP_201_CREATED, tags=["Transações"])
def create_transaction(tx_data: TransactionCreate):
    tx = state.add_transaction(
        bank_account_id=tx_data.bankAccountId,
        type_=tx_data.type,
        amount=tx_data.amount,
        description=tx_data.description,
        destination_bank_account_id=tx_data.destinationBankAccountId,
        transaction_category_id=tx_data.transactionCategoryId
    )
    if not tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Conta bancária '{tx_data.bankAccountId}' não encontrada"
        )
    return tx

@app.patch("/api/transactions/{id}", response_model=Transaction, tags=["Transações"])
def update_transaction(id: str, tx_update: TransactionUpdate):
    tx = state.update_transaction(
        tx_id=id,
        amount=tx_update.amount,
        description=tx_update.description,
        type_=tx_update.type,
        destination_bank_account_id=tx_update.destinationBankAccountId,
        transaction_category_id=tx_update.transactionCategoryId
    )
    if not tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transação com ID '{id}' não encontrada"
        )
    return tx

@app.delete("/api/transactions/{id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Transações"])
def delete_transaction(id: str):
    success = state.delete_transaction(id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transação com ID '{id}' não encontrada"
        )
    return None


# --- Endpoints de Metas (Goals) ---

@app.get("/api/goals", response_model=List[Goal], tags=["Metas"])
def get_goals():
    return state.get_goals()

@app.post("/api/goals", response_model=Goal, status_code=status.HTTP_201_CREATED, tags=["Metas"])
def create_goal(goal_data: GoalCreate):
    new_goal = state.add_goal(
        user_id="usr_lucas123",
        name=goal_data.name,
        target_amount=goal_data.targetAmount,
        deadline_date=goal_data.deadlineDate,
        bank_account_id=goal_data.bankAccountId
    )
    return new_goal

@app.patch("/api/goals/{id}", response_model=Goal, tags=["Metas"])
def update_goal(id: str, goal_update: GoalUpdate):
    goal = state.update_goal(
        goal_id=id,
        name=goal_update.name,
        target_amount=goal_update.targetAmount,
        current_amount=goal_update.currentAmount,
        status=goal_update.status,
        deadline_date=goal_update.deadlineDate,
        bank_account_id=goal_update.bankAccountId
    )
    if not goal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Meta com ID '{id}' não encontrada"
        )
    return goal

@app.delete("/api/goals/{id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Metas"])
def delete_goal(id: str):
    success = state.delete_goal(id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Meta com ID '{id}' não encontrada"
        )
    return None

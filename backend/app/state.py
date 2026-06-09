import os
import json
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import uuid
from app.schemas import (
    User, BankAccount, Goal, Transaction, TransactionType, GoalStatus, 
    Gender, BankAccountType, Currency
)

class AppState:
    def _get_db_path(self) -> str:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        parent_dir = os.path.dirname(current_dir)
        return os.path.join(parent_dir, "state_persistence.json")

    def save_state(self):
        try:
            data = {
                "users": {uid: u.model_dump(mode='json') for uid, u in self.users.items()},
                "accounts": {aid: acc.model_dump(mode='json') for aid, acc in self.accounts.items()},
                "goals": {gid: g.model_dump(mode='json') for gid, g in self.goals.items()},
                "transactions": [tx.model_dump(mode='json') for tx in self.transactions]
            }
            with open(self._get_db_path(), "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"Erro ao salvar estado: {e}")

    def load_state(self) -> bool:
        db_path = self._get_db_path()
        if not os.path.exists(db_path):
            return False
        try:
            with open(db_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            self.users = {uid: User.model_validate(u) for uid, u in data.get("users", {}).items()}
            self.accounts = {aid: BankAccount.model_validate(acc) for aid, acc in data.get("accounts", {}).items()}
            self.goals = {gid: Goal.model_validate(g) for gid, g in data.get("goals", {}).items()}
            self.transactions = [Transaction.model_validate(tx) for tx in data.get("transactions", [])]
            return True
        except Exception as e:
            print(f"Erro ao carregar estado: {e}")
            return False

    def __init__(self):
        # Armazenamento OAuth2 em memória (estes dados não são persistidos)
        # { auth_code: { "user_id": "...", "code_challenge": "...", "code_challenge_method": "...", "expires_at": ... } }
        self.auth_codes: Dict[str, dict] = {}
        # { refresh_token: { "user_id": "...", "client_id": "...", "expires_at": ... } }
        self.refresh_tokens: Dict[str, dict] = {}

        # Tentar carregar estado anterior
        if self.load_state():
            return

        # Estado inicial padrão se não houver persistência
        now = datetime.now()
        
        self.users: Dict[str, User] = {
            "usr_lucas123": User(
                id="usr_lucas123",
                name="Lucas Antunes",
                email="lucas@koin.com",
                password="123456",
                gender=Gender.male,
                creationDate=now - timedelta(days=30)
            )
        }
        
        self.accounts: Dict[str, BankAccount] = {
            "acc_wallet_01": BankAccount(
                id="acc_wallet_01",
                userId="usr_lucas123",
                name="Carteira Principal",
                balance=10300.00,
                type=BankAccountType.checking,
                currency=Currency.brl
            )
        }
        
        self.goals: Dict[str, Goal] = {
            "goal_01": Goal(
                id="goal_01",
                userId="usr_lucas123",
                name="Viagem Japão (1 ano)",
                targetAmount=8000.00,
                currentAmount=5200.00,
                status=GoalStatus.inProgress,
                deadlineDate=now + timedelta(days=365)
            ),
            "goal_02": Goal(
                id="goal_02",
                userId="usr_lucas123",
                name="Troca de Carro (5 anos)",
                targetAmount=100000.00,
                currentAmount=31800.00,
                status=GoalStatus.inProgress,
                deadlineDate=now + timedelta(days=1825)
            ),
            "goal_03": Goal(
                id="goal_03",
                userId="usr_lucas123",
                name="Reserva de Emergência",
                targetAmount=5000.00,
                currentAmount=5000.00,
                status=GoalStatus.completed,
                deadlineDate=now - timedelta(days=5)
            )
        }
        
        # Lista de transações (as mais recentes no início)
        self.transactions: List[Transaction] = [
            Transaction(
                id="tx_01",
                bankAccountId="acc_wallet_01",
                type=TransactionType.expense,
                amount=45.0,
                description="Almoço Executivo",
                transactionDate=now,
                creationDate=now
            ),
            Transaction(
                id="tx_02",
                bankAccountId="acc_wallet_01",
                type=TransactionType.income,
                amount=20.0,
                description="Economia Diária Hábito",
                transactionDate=now,
                creationDate=now
            ),
            Transaction(
                id="tx_03",
                bankAccountId="acc_wallet_01",
                type=TransactionType.expense,
                amount=8.5,
                description="Passagem Ônibus",
                transactionDate=now - timedelta(days=1),
                creationDate=now - timedelta(days=1)
            ),
            Transaction(
                id="tx_04",
                bankAccountId="acc_wallet_01",
                type=TransactionType.expense,
                amount=120.0,
                description="Supermercado Mensal",
                transactionDate=now - timedelta(days=1),
                creationDate=now - timedelta(days=1)
            ),
            Transaction(
                id="tx_05",
                bankAccountId="acc_wallet_01",
                type=TransactionType.income,
                amount=12.4,
                description="Rendimento Poupança",
                transactionDate=now - timedelta(days=5),
                creationDate=now - timedelta(days=5)
            )
        ]

        self.save_state()

    # --- Métodos OAuth2 ---
    def create_auth_code(self, user_id: str, code_challenge: str, code_challenge_method: str) -> str:
        code = f"auth_code_{uuid.uuid4().hex}"
        self.auth_codes[code] = {
            "user_id": user_id,
            "code_challenge": code_challenge,
            "code_challenge_method": code_challenge_method,
            "expires_at": datetime.now() + timedelta(minutes=10)
        }
        return code

    def validate_and_consume_auth_code(self, code: str) -> Optional[dict]:
        auth_data = self.auth_codes.get(code)
        if not auth_data:
            return None
        # Remove para uso único
        del self.auth_codes[code]
        # Verifica expiração
        if auth_data["expires_at"] < datetime.now():
            return None
        return auth_data

    def create_refresh_token(self, user_id: str, client_id: str) -> str:
        token = f"refresh_token_{uuid.uuid4().hex}"
        self.refresh_tokens[token] = {
            "user_id": user_id,
            "client_id": client_id,
            "expires_at": datetime.now() + timedelta(days=30)
        }
        return token

    def validate_and_consume_refresh_token(self, token: str) -> Optional[dict]:
        refresh_data = self.refresh_tokens.get(token)
        if not refresh_data:
            return None
        # Note: alguns servidores rotacionam refresh tokens. Para fins didáticos, mantemos ou removemos.
        # Vamos remover o antigo para segurança de rotação
        del self.refresh_tokens[token]
        if refresh_data["expires_at"] < datetime.now():
            return None
        return refresh_data

    def revoke_refresh_token(self, token: str) -> bool:
        if token in self.refresh_tokens:
            del self.refresh_tokens[token]
            return True
        return False

    # --- Métodos de Usuários ---
    def add_user(self, name: str, email: str, password: str, gender: Gender) -> Optional[User]:
        for u in self.users.values():
            if u.email == email:
                return None
        user_id = f"usr_{uuid.uuid4().hex[:8]}"
        new_user = User(
            id=user_id,
            name=name,
            email=email,
            password=password,
            gender=gender,
            creationDate=datetime.now()
        )
        self.users[user_id] = new_user
        self.save_state()
        return new_user

    def update_user(self, user_id: str, name: Optional[str] = None, gender: Optional[Gender] = None) -> Optional[User]:
        user = self.users.get(user_id)
        if not user:
            return None
        if name is not None:
            user.name = name
        if gender is not None:
            user.gender = gender
        self.save_state()
        return user

    # --- Métodos de Contas Bancárias ---
    def add_bank_account(self, user_id: str, name: str, balance: float, type_: BankAccountType, currency: Currency) -> BankAccount:
        acc_id = f"acc_{uuid.uuid4().hex[:8]}"
        new_acc = BankAccount(
            id=acc_id,
            userId=user_id,
            name=name,
            balance=balance,
            type=type_,
            currency=currency
        )
        self.accounts[acc_id] = new_acc
        self.save_state()
        return new_acc

    def update_bank_account(self, acc_id: str, name: Optional[str] = None, type_: Optional[BankAccountType] = None, currency: Optional[Currency] = None) -> Optional[BankAccount]:
        account = self.accounts.get(acc_id)
        if not account:
            return None
        if name is not None:
            account.name = name
        if type_ is not None:
            account.type = type_
        if currency is not None:
            account.currency = currency
        self.save_state()
        return account

    def delete_bank_account(self, acc_id: str) -> bool:
        if acc_id in self.accounts:
            self.transactions = [tx for tx in self.transactions if tx.bankAccountId != acc_id and tx.destinationBankAccountId != acc_id]
            for goal in self.goals.values():
                if goal.bankAccountId == acc_id:
                    goal.bankAccountId = None
                    goal.currentAmount = 0.0
                    goal.status = GoalStatus.inProgress
            del self.accounts[acc_id]
            self.save_state()
            return True
        return False

    # --- Métodos de Metas (Goals) ---
    def get_goals(self) -> List[Goal]:
        return list(self.goals.values())

    def add_goal(self, user_id: str, name: str, target_amount: float, deadline_date: datetime, bank_account_id: Optional[str] = None) -> Goal:
        goal_id = f"goal_{uuid.uuid4().hex[:8]}"
        new_goal = Goal(
            id=goal_id,
            userId=user_id,
            bankAccountId=bank_account_id,
            name=name,
            targetAmount=target_amount,
            currentAmount=0.0,
            status=GoalStatus.inProgress,
            deadlineDate=deadline_date
        )
        self.goals[goal_id] = new_goal
        self.save_state()
        return new_goal

    def update_goal(
        self, 
        goal_id: str, 
        name: Optional[str] = None,
        target_amount: Optional[float] = None,
        current_amount: Optional[float] = None, 
        status: Optional[GoalStatus] = None,
        deadline_date: Optional[datetime] = None,
        bank_account_id: Optional[str] = None
    ) -> Optional[Goal]:
        goal = self.goals.get(goal_id)
        if not goal:
            return None
        if name is not None:
            goal.name = name
        if target_amount is not None:
            goal.targetAmount = target_amount
        if current_amount is not None:
            goal.currentAmount = current_amount
        if status is not None:
            goal.status = status
        if deadline_date is not None:
            goal.deadlineDate = deadline_date
        if bank_account_id is not None:
            goal.bankAccountId = bank_account_id
                    
        # Check target vs current amount to update status automatically
        if goal.currentAmount >= goal.targetAmount:
            goal.status = GoalStatus.completed
        else:
            if goal.status == GoalStatus.completed:
                goal.status = GoalStatus.inProgress

        self.save_state()
        return goal

    def delete_goal(self, goal_id: str) -> bool:
        if goal_id in self.goals:
            del self.goals[goal_id]
            self.save_state()
            return True
        return False

    # --- Métodos de Transações ---
    def add_transaction(
        self, 
        bank_account_id: str, 
        type_: TransactionType, 
        amount: float, 
        description: str, 
        destination_bank_account_id: Optional[str] = None, 
        transaction_category_id: Optional[str] = None
    ) -> Optional[Transaction]:
        # Verifica se a conta bancária existe
        account = self.accounts.get(bank_account_id)
        if not account:
            return None
            
        # Atualiza o saldo
        if type_ == TransactionType.income:
            account.balance += amount
        elif type_ == TransactionType.expense:
            account.balance -= amount
        elif type_ == TransactionType.transfer:
            account.balance -= amount
            if destination_bank_account_id and destination_bank_account_id in self.accounts:
                self.accounts[destination_bank_account_id].balance += amount
                
        # Atualiza as metas vinculadas às contas envolvidas
        for goal in self.goals.values():
            if goal.bankAccountId == bank_account_id:
                if type_ == TransactionType.income:
                    goal.currentAmount += amount
                elif type_ == TransactionType.expense or type_ == TransactionType.transfer:
                    goal.currentAmount -= amount
            if type_ == TransactionType.transfer and destination_bank_account_id and goal.bankAccountId == destination_bank_account_id:
                goal.currentAmount += amount
                
            # Garante limites e status consistentes
            if goal.currentAmount < 0:
                goal.currentAmount = 0.0
            if goal.currentAmount >= goal.targetAmount:
                goal.status = GoalStatus.completed
            else:
                if goal.status == GoalStatus.completed:
                    goal.status = GoalStatus.inProgress
                
        now = datetime.now()
        new_tx = Transaction(
            id=f"tx_{int(now.timestamp() * 1000)}",
            bankAccountId=bank_account_id,
            destinationBankAccountId=destination_bank_account_id,
            type=type_,
            transactionCategoryId=transaction_category_id,
            amount=amount,
            description=description,
            transactionDate=now,
            creationDate=now
        )
        self.transactions.insert(0, new_tx)
        self.save_state()
        return new_tx

    def get_transaction_by_id(self, tx_id: str) -> Optional[Transaction]:
        for tx in self.transactions:
            if tx.id == tx_id:
                return tx
        return None

    def get_filtered_transactions(self, search: Optional[str] = None, type_: Optional[TransactionType] = None) -> List[Transaction]:
        result = self.transactions
        if search:
            search_lower = search.lower()
            result = [tx for tx in result if search_lower in tx.description.lower()]
        if type_:
            result = [tx for tx in result if tx.type == type_]
        return result

    def update_transaction(
        self, 
        tx_id: str, 
        amount: Optional[float] = None, 
        description: Optional[str] = None, 
        type_: Optional[TransactionType] = None, 
        destination_bank_account_id: Optional[str] = None,
        transaction_category_id: Optional[str] = None
    ) -> Optional[Transaction]:
        tx = self.get_transaction_by_id(tx_id)
        if not tx:
            return None
            
        # 1. Reverter efeito de saldo e metas antigo
        acc = self.accounts.get(tx.bankAccountId)
        if acc:
            if tx.type == TransactionType.income:
                acc.balance -= tx.amount
            elif tx.type == TransactionType.expense:
                acc.balance += tx.amount
            elif tx.type == TransactionType.transfer:
                acc.balance += tx.amount
                if tx.destinationBankAccountId and tx.destinationBankAccountId in self.accounts:
                    self.accounts[tx.destinationBankAccountId].balance -= tx.amount
            
            # Reverte o efeito nas metas vinculadas
            for goal in self.goals.values():
                if goal.bankAccountId == tx.bankAccountId:
                    if tx.type == TransactionType.income:
                        goal.currentAmount -= tx.amount
                    elif tx.type == TransactionType.expense or tx.type == TransactionType.transfer:
                        goal.currentAmount += tx.amount
                if tx.type == TransactionType.transfer and tx.destinationBankAccountId and goal.bankAccountId == tx.destinationBankAccountId:
                    goal.currentAmount -= tx.amount
                
                if goal.currentAmount < 0:
                    goal.currentAmount = 0.0
                    
        # 2. Aplicar modificações
        if amount is not None:
            tx.amount = amount
        if description is not None:
            tx.description = description
        if type_ is not None:
            tx.type = type_
        if destination_bank_account_id is not None:
            tx.destinationBankAccountId = destination_bank_account_id
        if transaction_category_id is not None:
            tx.transactionCategoryId = transaction_category_id
            
        # 3. Aplicar efeito de saldo e metas novo
        if acc:
            if tx.type == TransactionType.income:
                acc.balance += tx.amount
            elif tx.type == TransactionType.expense:
                acc.balance -= tx.amount
            elif tx.type == TransactionType.transfer:
                acc.balance -= tx.amount
                if tx.destinationBankAccountId and tx.destinationBankAccountId in self.accounts:
                    self.accounts[tx.destinationBankAccountId].balance += tx.amount
            
            # Aplica o novo efeito nas metas vinculadas
            for goal in self.goals.values():
                if goal.bankAccountId == tx.bankAccountId:
                    if tx.type == TransactionType.income:
                        goal.currentAmount += tx.amount
                    elif tx.type == TransactionType.expense or tx.type == TransactionType.transfer:
                        goal.currentAmount -= tx.amount
                if tx.type == TransactionType.transfer and tx.destinationBankAccountId and goal.bankAccountId == tx.destinationBankAccountId:
                    goal.currentAmount += tx.amount
                
                # Garante limites e status consistentes
                if goal.currentAmount < 0:
                    goal.currentAmount = 0.0
                if goal.currentAmount >= goal.targetAmount:
                    goal.status = GoalStatus.completed
                else:
                    if goal.status == GoalStatus.completed:
                        goal.status = GoalStatus.inProgress
                    
        self.save_state()
        return tx

    def delete_transaction(self, tx_id: str) -> bool:
        tx = self.get_transaction_by_id(tx_id)
        if not tx:
            return False
            
        # Reverte efeito de saldo e metas
        acc = self.accounts.get(tx.bankAccountId)
        if acc:
            if tx.type == TransactionType.income:
                acc.balance -= tx.amount
            elif tx.type == TransactionType.expense:
                acc.balance += tx.amount
            elif tx.type == TransactionType.transfer:
                acc.balance += tx.amount
                if tx.destinationBankAccountId and tx.destinationBankAccountId in self.accounts:
                    self.accounts[tx.destinationBankAccountId].balance -= tx.amount
            
            # Reverte o efeito nas metas vinculadas
            for goal in self.goals.values():
                if goal.bankAccountId == tx.bankAccountId:
                    if tx.type == TransactionType.income:
                        goal.currentAmount -= tx.amount
                    elif tx.type == TransactionType.expense or tx.type == TransactionType.transfer:
                        goal.currentAmount += tx.amount
                if tx.type == TransactionType.transfer and tx.destinationBankAccountId and goal.bankAccountId == tx.destinationBankAccountId:
                    goal.currentAmount -= tx.amount
                
                # Garante limites e status consistentes
                if goal.currentAmount < 0:
                    goal.currentAmount = 0.0
                if goal.currentAmount >= goal.targetAmount:
                    goal.status = GoalStatus.completed
                else:
                    if goal.status == GoalStatus.completed:
                        goal.status = GoalStatus.inProgress
                    
        self.transactions.remove(tx)
        self.save_state()
        return True

# Instância global do estado
state = AppState()

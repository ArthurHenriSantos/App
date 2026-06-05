from enum import Enum
from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional, List

# --- Enums ---

class Gender(str, Enum):
    male = "male"
    female = "female"
    other = "other"
    notSpecified = "notSpecified"

class BankAccountType(str, Enum):
    checking = "checking"
    savings = "savings"
    cash = "cash"
    creditCard = "creditCard"

class Currency(str, Enum):
    brl = "brl"
    usd = "usd"

class TransactionType(str, Enum):
    income = "income"
    expense = "expense"
    transfer = "transfer"

class GoalStatus(str, Enum):
    inProgress = "inProgress"
    completed = "completed"
    cancelled = "cancelled"


# --- Schemas ---

class User(BaseModel):
    id: str
    name: str
    email: str
    password: str
    gender: Gender
    creationDate: datetime

class UserLogin(BaseModel):
    email: str
    password: str

class UserRegister(BaseModel):
    name: str
    email: str
    password: str
    gender: Gender

class UserUpdate(BaseModel):
    name: Optional[str] = None
    gender: Optional[Gender] = None

class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    gender: Gender
    creationDate: datetime

class LoginResponse(BaseModel):
    token: str
    user: UserResponse


class BankAccount(BaseModel):
    id: str
    userId: str
    name: str
    balance: float
    type: BankAccountType
    currency: Currency

class BankAccountCreate(BaseModel):
    name: str
    balance: float
    type: BankAccountType
    currency: Currency

class BankAccountUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[BankAccountType] = None
    currency: Optional[Currency] = None


class Goal(BaseModel):
    id: str
    userId: str
    bankAccountId: Optional[str] = None
    name: str
    targetAmount: float
    currentAmount: float
    status: GoalStatus
    deadlineDate: datetime

class GoalCreate(BaseModel):
    name: str
    targetAmount: float
    deadlineDate: datetime
    bankAccountId: Optional[str] = None

class GoalUpdate(BaseModel):
    name: Optional[str] = None
    targetAmount: Optional[float] = None
    currentAmount: Optional[float] = None
    status: Optional[GoalStatus] = None
    deadlineDate: Optional[datetime] = None
    bankAccountId: Optional[str] = None


class Transaction(BaseModel):
    id: str
    bankAccountId: str
    destinationBankAccountId: Optional[str] = None
    type: TransactionType
    transactionCategoryId: Optional[str] = None
    amount: float
    description: str
    transactionDate: datetime
    creationDate: datetime

class TransactionCreate(BaseModel):
    bankAccountId: str
    type: TransactionType
    amount: float
    description: str
    destinationBankAccountId: Optional[str] = None
    transactionCategoryId: Optional[str] = None

class TransactionUpdate(BaseModel):
    amount: Optional[float] = None
    description: Optional[str] = None
    type: Optional[TransactionType] = None
    destinationBankAccountId: Optional[str] = None
    transactionCategoryId: Optional[str] = None

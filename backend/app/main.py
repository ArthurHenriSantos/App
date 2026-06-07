from fastapi import FastAPI, HTTPException, status, Query, Header, Form, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, RedirectResponse
from typing import List, Optional
import hashlib
import base64
import jwt
from datetime import datetime, timedelta

from app.schemas import (
    UserLogin, UserRegister, UserUpdate, LoginResponse, UserResponse,
    BankAccount, BankAccountCreate, BankAccountUpdate,
    Transaction, TransactionCreate, TransactionUpdate, TransactionType,
    Goal, GoalCreate, GoalUpdate, User
)
from app.state import state

JWT_SECRET = "koin_super_secret_jwt_key_2026!#"
JWT_ALGORITHM = "HS256"

def verify_pkce(code_verifier: str, code_challenge: str, method: str) -> bool:
    if not code_verifier or not code_challenge:
        return False
    if method == "S256":
        sha256_hash = hashlib.sha256(code_verifier.encode("utf-8")).digest()
        challenge = base64.urlsafe_b64encode(sha256_hash).decode("utf-8").rstrip("=")
        return challenge == code_challenge
    elif method == "plain" or not method:
        return code_verifier == code_challenge
    return False

def create_jwt(user_id: str, name: str, email: str, expires_delta: timedelta) -> str:
    now = datetime.utcnow()
    payload = {
        "sub": user_id,
        "nome": name,
        "email": email,
        "iat": now,
        "exp": now + expires_delta
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def get_current_user(authorization: Optional[str] = Header(None)) -> User:
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de autenticação ausente."
        )
    try:
        parts = authorization.split(" ")
        if len(parts) != 2 or parts[0].lower() != "bearer":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Formato do token inválido. Use Bearer <token>."
            )
        token = parts[1]
        
        # Permitir tokens de teste antigos
        if token.startswith("mock_jwt_token_for_"):
            user_id = token.replace("mock_jwt_token_for_", "")
            user = state.users.get(user_id)
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Usuário inválido."
                )
            return user

        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token de acesso inválido: identificador do usuário ausente."
            )
        user = state.users.get(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Usuário do token não encontrado."
            )
        return user
    except (ValueError, jwt.PyJWTError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de acesso inválido ou expirado."
        )

def get_login_html(
    response_type: str,
    client_id: str,
    redirect_uri: str,
    code_challenge: str,
    code_challenge_method: str,
    state_param: Optional[str] = None,
    scope: Optional[str] = None,
    error: Optional[str] = None
) -> str:
    state_input = f'<input type="hidden" name="state" value="{state_param}">' if state_param else ''
    scope_input = f'<input type="hidden" name="scope" value="{scope}">' if scope else ''
    error_banner = f'''
    <div class="error-banner">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="error-icon">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
        </svg>
        <span>{error}</span>
    </div>
    ''' if error else ''

    html = f'''
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Koin - Autorizar Acesso</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            * {{
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            }}
            body {{
                background-color: #0f172a;
                background-image: 
                    radial-gradient(at 0% 0%, rgba(99, 102, 241, 0.15) 0px, transparent 50%),
                    radial-gradient(at 100% 100%, rgba(6, 182, 212, 0.12) 0px, transparent 50%);
                color: #f8fafc;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                padding: 20px;
            }}
            .container {{
                width: 100%;
                max-width: 440px;
            }}
            .card {{
                background: rgba(30, 41, 59, 0.7);
                backdrop-filter: blur(16px);
                -webkit-backdrop-filter: blur(16px);
                border: 1px solid rgba(255, 255, 255, 0.08);
                border-radius: 24px;
                padding: 40px 32px;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3), 0 10px 10px -5px rgba(0, 0, 0, 0.2);
            }}
            .logo-area {{
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 32px;
            }}
            .logo-icon {{
                background: rgba(99, 102, 241, 0.15);
                border: 1px solid rgba(99, 102, 241, 0.25);
                border-radius: 16px;
                padding: 12px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                color: #6366f1;
                margin-bottom: 16px;
                box-shadow: 0 0 20px rgba(99, 102, 241, 0.2);
            }}
            .logo-text {{
                font-size: 28px;
                font-weight: 700;
                letter-spacing: 0.5px;
                background: linear-gradient(135deg, #ffffff 0%, #cbd5e1 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }}
            .logo-subtext {{
                font-size: 14px;
                color: #94a3b8;
                margin-top: 6px;
                text-align: center;
            }}
            .error-banner {{
                background-color: rgba(239, 68, 68, 0.1);
                border: 1px solid rgba(239, 68, 68, 0.2);
                border-radius: 12px;
                padding: 12px 16px;
                margin-bottom: 24px;
                display: flex;
                align-items: center;
                gap: 12px;
                color: #f87171;
                font-size: 14px;
                font-weight: 500;
            }}
            .error-icon {{
                width: 20px;
                height: 20px;
                flex-shrink: 0;
            }}
            .form-group {{
                margin-bottom: 20px;
            }}
            .form-label {{
                display: block;
                font-size: 14px;
                font-weight: 600;
                color: #cbd5e1;
                margin-bottom: 8px;
            }}
            .input-wrapper {{
                position: relative;
            }}
            .form-input {{
                width: 100%;
                background: rgba(15, 23, 42, 0.6);
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 14px;
                padding: 14px 16px 14px 44px;
                color: #f8fafc;
                font-size: 15px;
                outline: none;
                transition: all 0.2s ease;
            }}
            .form-input:focus {{
                border-color: #6366f1;
                box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
                background: rgba(15, 23, 42, 0.8);
            }}
            .input-icon {{
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                color: #94a3b8;
                width: 20px;
                height: 20px;
                pointer-events: none;
                transition: color 0.2s ease;
            }}
            .form-input:focus + .input-icon {{
                color: #6366f1;
            }}
            .submit-btn {{
                width: 100%;
                background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
                border: none;
                border-radius: 14px;
                padding: 16px;
                color: #ffffff;
                font-size: 16px;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.2s ease;
                box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
                margin-top: 10px;
            }}
            .submit-btn:hover {{
                transform: translateY(-1px);
                box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
            }}
            .submit-btn:active {{
                transform: translateY(0);
            }}
            .footer {{
                text-align: center;
                margin-top: 24px;
                font-size: 12px;
                color: #64748b;
            }}
            .switch-link {{
                text-align: center;
                margin-top: 20px;
                font-size: 14px;
                color: #94a3b8;
            }}
            .switch-link a {{
                color: #6366f1;
                text-decoration: none;
                font-weight: 600;
            }}
            .switch-link a:hover {{
                text-decoration: underline;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="card">
                <div class="logo-area">
                    <div class="logo-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M21.21 15.89A10 10 0 1 1 8 2.83"></path>
                            <path d="M22 12A10 10 0 0 0 12 2v10z"></path>
                        </svg>
                    </div>
                    <h1 class="logo-text">Koin Auth</h1>
                    <p class="logo-subtext">O aplicativo <strong>{client_id}</strong> solicita acesso às suas finanças.</p>
                </div>

                {error_banner}

                <form method="POST" action="/api/oauth2/authorize">
                    <input type="hidden" name="response_type" value="{response_type}">
                    <input type="hidden" name="client_id" value="{client_id}">
                    <input type="hidden" name="redirect_uri" value="{redirect_uri}">
                    <input type="hidden" name="code_challenge" value="{code_challenge}">
                    <input type="hidden" name="code_challenge_method" value="{code_challenge_method}">
                    {state_input}
                    {scope_input}

                    <div class="form-group">
                        <label class="form-label" for="email">E-mail</label>
                        <div class="input-wrapper">
                            <input class="form-input" type="email" id="email" name="email" placeholder="nome@exemplo.com" required autocomplete="email" autofocus>
                            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75" />
                            </svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">Senha</label>
                        <div class="input-wrapper">
                            <input class="form-input" type="password" id="password" name="password" placeholder="••••••••" required autocomplete="current-password">
                            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" />
                            </svg>
                        </div>
                    </div>

                    <button class="submit-btn" type="submit">Autorizar e Entrar</button>
                </form>

                <div class="switch-link">
                    Não tem uma conta? <a href="/api/oauth2/register?response_type={response_type}&client_id={client_id}&redirect_uri={redirect_uri}&code_challenge={code_challenge}&code_challenge_method={code_challenge_method}{f'&state={state_param}' if state_param else ''}{f'&scope={scope}' if scope else ''}">Cadastre-se</a>
                </div>
            </div>
            <div class="footer">
                Conexão segura Koin • Todos os direitos reservados.
            </div>
        </div>
    </body>
    </html>
    '''
    return html

def get_register_html(
    response_type: str,
    client_id: str,
    redirect_uri: str,
    code_challenge: str,
    code_challenge_method: str,
    state_param: Optional[str] = None,
    scope: Optional[str] = None,
    error: Optional[str] = None
) -> str:
    state_input = f'<input type="hidden" name="state" value="{state_param}">' if state_param else ''
    scope_input = f'<input type="hidden" name="scope" value="{scope}">' if scope else ''
    error_banner = f'''
    <div class="error-banner">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="error-icon">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
        </svg>
        <span>{error}</span>
    </div>
    ''' if error else ''

    html = f'''
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Koin - Criar Conta</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            * {{
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            }}
            body {{
                background-color: #0f172a;
                background-image: 
                    radial-gradient(at 0% 0%, rgba(99, 102, 241, 0.15) 0px, transparent 50%),
                    radial-gradient(at 100% 100%, rgba(6, 182, 212, 0.12) 0px, transparent 50%);
                color: #f8fafc;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                padding: 20px;
            }}
            .container {{
                width: 100%;
                max-width: 440px;
            }}
            .card {{
                background: rgba(30, 41, 59, 0.7);
                backdrop-filter: blur(16px);
                -webkit-backdrop-filter: blur(16px);
                border: 1px solid rgba(255, 255, 255, 0.08);
                border-radius: 24px;
                padding: 40px 32px;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3), 0 10px 10px -5px rgba(0, 0, 0, 0.2);
            }}
            .logo-area {{
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 28px;
            }}
            .logo-icon {{
                background: rgba(99, 102, 241, 0.15);
                border: 1px solid rgba(99, 102, 241, 0.25);
                border-radius: 16px;
                padding: 12px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                color: #6366f1;
                margin-bottom: 16px;
                box-shadow: 0 0 20px rgba(99, 102, 241, 0.2);
            }}
            .logo-text {{
                font-size: 28px;
                font-weight: 700;
                letter-spacing: 0.5px;
                background: linear-gradient(135deg, #ffffff 0%, #cbd5e1 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }}
            .logo-subtext {{
                font-size: 14px;
                color: #94a3b8;
                margin-top: 6px;
                text-align: center;
            }}
            .error-banner {{
                background-color: rgba(239, 68, 68, 0.1);
                border: 1px solid rgba(239, 68, 68, 0.2);
                border-radius: 12px;
                padding: 12px 16px;
                margin-bottom: 24px;
                display: flex;
                align-items: center;
                gap: 12px;
                color: #f87171;
                font-size: 14px;
                font-weight: 500;
            }}
            .error-icon {{
                width: 20px;
                height: 20px;
                flex-shrink: 0;
            }}
            .form-group {{
                margin-bottom: 16px;
            }}
            .form-label {{
                display: block;
                font-size: 14px;
                font-weight: 600;
                color: #cbd5e1;
                margin-bottom: 6px;
            }}
            .input-wrapper {{
                position: relative;
            }}
            .form-input {{
                width: 100%;
                background: rgba(15, 23, 42, 0.6);
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 14px;
                padding: 14px 16px 14px 44px;
                color: #f8fafc;
                font-size: 15px;
                outline: none;
                transition: all 0.2s ease;
            }}
            .form-input:focus {{
                border-color: #6366f1;
                box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
                background: rgba(15, 23, 42, 0.8);
            }}
            .select-input {{
                padding-left: 44px;
                appearance: none;
                -webkit-appearance: none;
                background-image: url("data:image/svg+xml;utf8,<svg fill='none' height='24' viewBox='0 0 24 24' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5H7z' fill='%2394a3b8'/></svg>");
                background-repeat: no-repeat;
                background-position: right 14px center;
            }}
            .input-icon {{
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                color: #94a3b8;
                width: 20px;
                height: 20px;
                pointer-events: none;
            }}
            .form-input:focus + .input-icon {{
                color: #6366f1;
            }}
            .submit-btn {{
                width: 100%;
                background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
                border: none;
                border-radius: 14px;
                padding: 16px;
                color: #ffffff;
                font-size: 16px;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.2s ease;
                box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
                margin-top: 10px;
            }}
            .submit-btn:hover {{
                transform: translateY(-1px);
                box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
            }}
            .switch-link {{
                text-align: center;
                margin-top: 20px;
                font-size: 14px;
                color: #94a3b8;
            }}
            .switch-link a {{
                color: #6366f1;
                text-decoration: none;
                font-weight: 600;
            }}
            .switch-link a:hover {{
                text-decoration: underline;
            }}
            .footer {{
                text-align: center;
                margin-top: 24px;
                font-size: 12px;
                color: #64748b;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="card">
                <div class="logo-area">
                    <div class="logo-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                            <circle cx="8.5" cy="7" r="4"></circle>
                            <line x1="20" y1="8" x2="20" y2="14"></line>
                            <line x1="17" y1="11" x2="23" y2="11"></line>
                        </svg>
                    </div>
                    <h1 class="logo-text">Criar Conta</h1>
                    <p class="logo-subtext">Registre-se para acessar o <strong>{client_id}</strong>.</p>
                </div>

                {error_banner}

                <form method="POST" action="/api/oauth2/register">
                    <input type="hidden" name="response_type" value="{response_type}">
                    <input type="hidden" name="client_id" value="{client_id}">
                    <input type="hidden" name="redirect_uri" value="{redirect_uri}">
                    <input type="hidden" name="code_challenge" value="{code_challenge}">
                    <input type="hidden" name="code_challenge_method" value="{code_challenge_method}">
                    {state_input}
                    {scope_input}

                    <div class="form-group">
                        <label class="form-label" for="name">Nome Completo</label>
                        <div class="input-wrapper">
                            <input class="form-input" type="text" id="name" name="name" placeholder="Seu nome" required autofocus>
                            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                            </svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="email">E-mail</label>
                        <div class="input-wrapper">
                            <input class="form-input" type="email" id="email" name="email" placeholder="nome@exemplo.com" required>
                            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75" />
                            </svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">Senha</label>
                        <div class="input-wrapper">
                            <input class="form-input" type="password" id="password" name="password" placeholder="Mínimo 6 caracteres" minlength="6" required>
                            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" />
                            </svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="gender">Gênero</label>
                        <div class="input-wrapper">
                            <select class="form-input select-input" id="gender" name="gender" required>
                                <option value="male">Masculino</option>
                                <option value="female">Feminino</option>
                                <option value="other">Outro</option>
                            </select>
                            <svg class="input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M18 18.72a9.094 9.094 0 003.741-.479 3 3 0 00-4.682-2.72m.94 3.198l.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0112 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 016 18.719m12 0a5.971 5.971 0 00-.941-3.197m0 0A5.995 5.995 0 0012 12.75a5.995 5.995 0 00-5.058 2.772m0 0a3 3 0 00-4.681 2.72 8.986 8.986 0 003.74.477m.94-3.197a5.971 5.971 0 00-.94 3.197M15 6.75a3 3 0 11-6 0 3 3 0 016 0zm6 3a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0zm-13.5 0a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0z" />
                            </svg>
                        </div>
                    </div>

                    <button class="submit-btn" type="submit">Registrar e Entrar</button>
                </form>

                <div class="switch-link">
                    Já tem uma conta? <a href="/api/oauth2/authorize?response_type={response_type}&client_id={client_id}&redirect_uri={redirect_uri}&code_challenge={code_challenge}&code_challenge_method={code_challenge_method}{f'&state={state_param}' if state_param else ''}{f'&scope={scope}' if scope else ''}">Faça Login</a>
                </div>
            </div>
            <div class="footer">
                Conexão segura Koin • Todos os direitos reservados.
            </div>
        </div>
    </body>
    </html>
    '''
    return html

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
    from app.schemas import BankAccountType, Currency
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
    # Cria conta bancária padrão automaticamente para o novo usuário
    state.add_bank_account(
        user_id=user.id,
        name="Minha Carteira",
        balance=0.0,
        type_=BankAccountType.checking,
        currency=Currency.brl
    )
    return LoginResponse(
        token=create_jwt(user.id, user.name, user.email, timedelta(hours=24)),
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
        token=create_jwt(user.id, user.name, user.email, timedelta(hours=24)),
        user=UserResponse(
            id=user.id,
            name=user.name,
            email=user.email,
            gender=user.gender,
            creationDate=user.creationDate
        )
    )

# --- Endpoints OAuth2 ---

@app.get("/api/oauth2/authorize", response_class=HTMLResponse, tags=["OAuth2"])
def oauth2_authorize(
    response_type: str,
    client_id: str,
    redirect_uri: str,
    code_challenge: str,
    code_challenge_method: str = "S256",
    state_param: Optional[str] = Query(None, alias="state"),
    scope: Optional[str] = None,
    error: Optional[str] = None
):
    if response_type != "code":
        raise HTTPException(status_code=400, detail="response_type inválido. Apenas 'code' é suportado.")
    
    return HTMLResponse(
        content=get_login_html(
            response_type=response_type,
            client_id=client_id,
            redirect_uri=redirect_uri,
            code_challenge=code_challenge,
            code_challenge_method=code_challenge_method,
            state_param=state_param,
            scope=scope,
            error=error
        )
    )

@app.post("/api/oauth2/authorize", tags=["OAuth2"])
def oauth2_post_authorize(
    email: str = Form(...),
    password: str = Form(...),
    response_type: str = Form(...),
    client_id: str = Form(...),
    redirect_uri: str = Form(...),
    code_challenge: str = Form(...),
    code_challenge_method: str = Form(...),
    state_param: Optional[str] = Form(None, alias="state"),
    scope: Optional[str] = Form(None)
):
    user = None
    for u in state.users.values():
        if u.email == email:
            user = u
            break
            
    if not user or password != user.password:
        return HTMLResponse(
            content=get_login_html(
                response_type=response_type,
                client_id=client_id,
                redirect_uri=redirect_uri,
                code_challenge=code_challenge,
                code_challenge_method=code_challenge_method,
                state_param=state_param,
                scope=scope,
                error="Credenciais inválidas. Tente novamente."
            ),
            status_code=status.HTTP_401_UNAUTHORIZED
        )
        
    code = state.create_auth_code(
        user_id=user.id,
        code_challenge=code_challenge,
        code_challenge_method=code_challenge_method
    )
    
    redirect_url = f"{redirect_uri}?code={code}"
    if state_param:
        redirect_url += f"&state={state_param}"
        
    return RedirectResponse(url=redirect_url, status_code=status.HTTP_302_FOUND)

@app.get("/api/oauth2/register", response_class=HTMLResponse, tags=["OAuth2"])
def oauth2_register(
    response_type: str,
    client_id: str,
    redirect_uri: str,
    code_challenge: str,
    code_challenge_method: str = "S256",
    state_param: Optional[str] = Query(None, alias="state"),
    scope: Optional[str] = None,
    error: Optional[str] = None
):
    return HTMLResponse(
        content=get_register_html(
            response_type=response_type,
            client_id=client_id,
            redirect_uri=redirect_uri,
            code_challenge=code_challenge,
            code_challenge_method=code_challenge_method,
            state_param=state_param,
            scope=scope,
            error=error
        )
    )

@app.post("/api/oauth2/register", tags=["OAuth2"])
def oauth2_post_register(
    name: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    gender: str = Form(...),
    response_type: str = Form(...),
    client_id: str = Form(...),
    redirect_uri: str = Form(...),
    code_challenge: str = Form(...),
    code_challenge_method: str = Form(...),
    state_param: Optional[str] = Form(None, alias="state"),
    scope: Optional[str] = Form(None)
):
    from app.schemas import Gender as SchemasGender, BankAccountType, Currency
    try:
        user_gender = SchemasGender(gender)
    except ValueError:
        user_gender = SchemasGender.other
        
    # Adiciona o usuário no estado
    user = state.add_user(
        name=name,
        email=email,
        password=password,
        gender=user_gender
    )
    if not user:
        return HTMLResponse(
            content=get_register_html(
                response_type=response_type,
                client_id=client_id,
                redirect_uri=redirect_uri,
                code_challenge=code_challenge,
                code_challenge_method=code_challenge_method,
                state_param=state_param,
                scope=scope,
                error="Este e-mail já está cadastrado no sistema."
            ),
            status_code=status.HTTP_400_BAD_REQUEST
        )
    
    # Cria uma conta bancária padrão para o novo usuário
    state.add_bank_account(
        user_id=user.id,
        name="Minha Carteira",
        balance=0.0,
        type_=BankAccountType.checking,
        currency=Currency.brl
    )

    # Gera o código de autorização para o novo usuário
    code = state.create_auth_code(
        user_id=user.id,
        code_challenge=code_challenge,
        code_challenge_method=code_challenge_method
    )
    
    redirect_url = f"{redirect_uri}?code={code}"
    if state_param:
        redirect_url += f"&state={state_param}"
        
    return RedirectResponse(url=redirect_url, status_code=status.HTTP_302_FOUND)

@app.post("/api/oauth2/token", tags=["OAuth2"])
def oauth2_token(
    grant_type: str = Form(...),
    client_id: str = Form(...),
    code: Optional[str] = Form(None),
    code_verifier: Optional[str] = Form(None),
    redirect_uri: Optional[str] = Form(None),
    refresh_token: Optional[str] = Form(None)
):
    if grant_type == "authorization_code":
        if not code or not code_verifier:
            raise HTTPException(status_code=400, detail="code e code_verifier são obrigatórios para grant_type='authorization_code'")
            
        auth_data = state.validate_and_consume_auth_code(code)
        if not auth_data:
            raise HTTPException(status_code=400, detail="Código de autorização inválido ou expirado.")
            
        if not verify_pkce(code_verifier, auth_data["code_challenge"], auth_data["code_challenge_method"]):
            raise HTTPException(status_code=400, detail="Verificação do code_verifier (PKCE) falhou.")
            
        user_id = auth_data["user_id"]
        user = state.users.get(user_id)
        if not user:
            raise HTTPException(status_code=400, detail="Usuário não encontrado.")
            
    elif grant_type == "refresh_token":
        if not refresh_token:
            raise HTTPException(status_code=400, detail="refresh_token é obrigatório para grant_type='refresh_token'")
            
        refresh_data = state.validate_and_consume_refresh_token(refresh_token)
        if not refresh_data:
            raise HTTPException(status_code=400, detail="Refresh token inválido ou expirado.")
            
        user_id = refresh_data["user_id"]
        user = state.users.get(user_id)
        if not user:
            raise HTTPException(status_code=400, detail="Usuário não encontrado.")
            
    else:
        raise HTTPException(status_code=400, detail="grant_type não suportado. Use 'authorization_code' ou 'refresh_token'.")
        
    access_token_expires = timedelta(hours=1)
    access_token = create_jwt(user.id, user.name, user.email, access_token_expires)
    new_refresh_token = state.create_refresh_token(user.id, client_id)
    id_token = create_jwt(user.id, user.name, user.email, timedelta(hours=24))
    
    return {
        "access_token": access_token,
        "token_type": "Bearer",
        "expires_in": int(access_token_expires.total_seconds()),
        "refresh_token": new_refresh_token,
        "id_token": id_token
    }

@app.get("/api/users/me", response_model=UserResponse, tags=["Usuários"])
def get_me(current_user: User = Depends(get_current_user)):
    return UserResponse(
        id=current_user.id,
        name=current_user.name,
        email=current_user.email,
        gender=current_user.gender,
        creationDate=current_user.creationDate
    )

@app.patch("/api/users/me", response_model=UserResponse, tags=["Usuários"])
def update_me(user_update: UserUpdate, current_user: User = Depends(get_current_user)):
    user = state.update_user(
        user_id=current_user.id,
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
def get_accounts(current_user: User = Depends(get_current_user)):
    return [acc for acc in state.accounts.values() if acc.userId == current_user.id]

@app.get("/api/accounts/primary", response_model=BankAccount, tags=["Contas Bancárias"])
def get_primary_account(current_user: User = Depends(get_current_user)):
    user_accounts = [acc for acc in state.accounts.values() if acc.userId == current_user.id]
    if not user_accounts:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nenhuma conta bancária disponível"
        )
    for acc in user_accounts:
        if acc.id == "acc_wallet_01":
            return acc
    return user_accounts[0]

@app.get("/api/accounts/{id}", response_model=BankAccount, tags=["Contas Bancárias"])
def get_account_by_id(id: str, current_user: User = Depends(get_current_user)):
    account = state.accounts.get(id)
    if not account or account.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conta não encontrada"
        )
    return account

@app.post("/api/accounts", response_model=BankAccount, status_code=status.HTTP_201_CREATED, tags=["Contas Bancárias"])
def create_account(account_data: BankAccountCreate, current_user: User = Depends(get_current_user)):
    account = state.add_bank_account(
        user_id=current_user.id,
        name=account_data.name,
        balance=account_data.balance,
        type_=account_data.type,
        currency=account_data.currency
    )
    return account

@app.patch("/api/accounts/{id}", response_model=BankAccount, tags=["Contas Bancárias"])
def update_account(id: str, account_data: BankAccountUpdate, current_user: User = Depends(get_current_user)):
    account = state.accounts.get(id)
    if not account or account.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Conta bancária '{id}' não encontrada"
        )
    account = state.update_bank_account(
        acc_id=id,
        name=account_data.name,
        type_=account_data.type,
        currency=account_data.currency
    )
    return account

@app.delete("/api/accounts/{id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Contas Bancárias"])
def delete_account(id: str, current_user: User = Depends(get_current_user)):
    account = state.accounts.get(id)
    if not account or account.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Conta bancária '{id}' não encontrada"
        )
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
    type: Optional[TransactionType] = Query(None, description="Filtrar por tipo (income, expense, transfer)"),
    bankAccountId: Optional[str] = Query(None, description="Filtrar por ID da conta bancária"),
    current_user: User = Depends(get_current_user)
):
    user_acc_ids = {acc.id for acc in state.accounts.values() if acc.userId == current_user.id}
    if bankAccountId:
        if bankAccountId not in user_acc_ids:
            raise HTTPException(status_code=400, detail="Conta bancária inválida ou não pertence ao usuário")
        user_acc_ids = {bankAccountId}
        
    all_filtered = state.get_filtered_transactions(search=search, type_=type)
    return [tx for tx in all_filtered if tx.bankAccountId in user_acc_ids or tx.destinationBankAccountId in user_acc_ids]

@app.get("/api/transactions/{id}", response_model=Transaction, tags=["Transações"])
def get_transaction(id: str, current_user: User = Depends(get_current_user)):
    tx = state.get_transaction_by_id(id)
    if not tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transação não encontrada"
        )
    account = state.accounts.get(tx.bankAccountId)
    if not account or account.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transação não encontrada"
        )
    return tx

@app.post("/api/transactions", response_model=Transaction, status_code=status.HTTP_201_CREATED, tags=["Transações"])
def create_transaction(tx_data: TransactionCreate, current_user: User = Depends(get_current_user)):
    account = state.accounts.get(tx_data.bankAccountId)
    if not account or account.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Conta bancária '{tx_data.bankAccountId}' não encontrada"
        )
    tx = state.add_transaction(
        bank_account_id=tx_data.bankAccountId,
        type_=tx_data.type,
        amount=tx_data.amount,
        description=tx_data.description,
        destination_bank_account_id=tx_data.destinationBankAccountId,
        transaction_category_id=tx_data.transactionCategoryId
    )
    return tx

@app.patch("/api/transactions/{id}", response_model=Transaction, tags=["Transações"])
def update_transaction(id: str, tx_update: TransactionUpdate, current_user: User = Depends(get_current_user)):
    tx = state.get_transaction_by_id(id)
    if not tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transação com ID '{id}' não encontrada"
        )
    account = state.accounts.get(tx.bankAccountId)
    if not account or account.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transação com ID '{id}' não encontrada"
        )
    tx = state.update_transaction(
        tx_id=id,
        amount=tx_update.amount,
        description=tx_update.description,
        type_=tx_update.type,
        destination_bank_account_id=tx_update.destinationBankAccountId,
        transaction_category_id=tx_update.transactionCategoryId
    )
    return tx

@app.delete("/api/transactions/{id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Transações"])
def delete_transaction(id: str, current_user: User = Depends(get_current_user)):
    tx = state.get_transaction_by_id(id)
    if not tx:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transação com ID '{id}' não encontrada"
        )
    account = state.accounts.get(tx.bankAccountId)
    if not account or account.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transação com ID '{id}' não encontrada"
        )
    success = state.delete_transaction(id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transação com ID '{id}' não encontrada"
        )
    return None


# --- Endpoints de Metas (Goals) ---

@app.get("/api/goals", response_model=List[Goal], tags=["Metas"])
def get_goals(current_user: User = Depends(get_current_user)):
    return [g for g in state.goals.values() if g.userId == current_user.id]

@app.get("/api/goals/{id}", response_model=Goal, tags=["Metas"])
def get_goal(id: str, current_user: User = Depends(get_current_user)):
    goal = state.goals.get(id)
    if not goal or goal.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Meta com ID '{id}' não encontrada"
        )
    return goal

@app.post("/api/goals", response_model=Goal, status_code=status.HTTP_201_CREATED, tags=["Metas"])
def create_goal(goal_data: GoalCreate, current_user: User = Depends(get_current_user)):
    new_goal = state.add_goal(
        user_id=current_user.id,
        name=goal_data.name,
        target_amount=goal_data.targetAmount,
        deadline_date=goal_data.deadlineDate,
        bank_account_id=goal_data.bankAccountId
    )
    return new_goal

@app.patch("/api/goals/{id}", response_model=Goal, tags=["Metas"])
def update_goal(id: str, goal_update: GoalUpdate, current_user: User = Depends(get_current_user)):
    goal = state.goals.get(id)
    if not goal or goal.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Meta com ID '{id}' não encontrada"
        )
    goal = state.update_goal(
        goal_id=id,
        name=goal_update.name,
        target_amount=goal_update.targetAmount,
        current_amount=goal_update.currentAmount,
        status=goal_update.status,
        deadline_date=goal_update.deadlineDate,
        bank_account_id=goal_update.bankAccountId
    )
    return goal

@app.delete("/api/goals/{id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Metas"])
def delete_goal(id: str, current_user: User = Depends(get_current_user)):
    goal = state.goals.get(id)
    if not goal or goal.userId != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Meta com ID '{id}' não encontrada"
        )
    success = state.delete_goal(id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Meta com ID '{id}' não encontrada"
        )
    return None

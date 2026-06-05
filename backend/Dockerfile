FROM python:3.11-slim

WORKDIR /workspace

# Instalar dependências primeiro para aproveitar o cache do Docker
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar os arquivos da aplicação
COPY ./app ./app

# Expor a porta 8000
EXPOSE 8000

# Executar a aplicação
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

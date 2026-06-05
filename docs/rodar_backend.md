# Rodar o backend

## Powershell
```
docker kill koin ; docker rm koin ; docker build -t koin . ; docker run -d -p 8000:8000 --name koin koin
```

## CMD
```
docker kill koin && docker rm koin && docker build -t koin . && docker run -d -p 8000:8000 --name koin koin
```
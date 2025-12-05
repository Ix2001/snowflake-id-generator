# Инструкция по установке Ingress Controller и настройке DNS

## Часть 1: Установка Ingress Controller

### Установка NGINX Ingress Controller

Выполните следующую команду для установки NGINX Ingress Controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

### Проверка установки

1. Проверьте, что поды Ingress Controller запущены:

```bash
kubectl get pods -n ingress-nginx
```

Должен быть запущен под с именем `ingress-nginx-controller-*`.

2. Проверьте наличие Service типа LoadBalancer:

```bash
kubectl get svc -n ingress-nginx
```

Должен быть сервис `ingress-nginx-controller` с типом `LoadBalancer`.

3. Получите внешний IP адрес LoadBalancer:

```bash
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

Запишите EXTERNAL-IP (может быть `<pending>` в локальных кластерах).

## Часть 2: Настройка DNS на локальной машине

### macOS/Linux

Отредактируйте файл `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Добавьте следующую строку (замените `<EXTERNAL-IP>` на IP адрес LoadBalancer или `127.0.0.1` для локального кластера):

```
127.0.0.1 snowflake.dev.local
```

Или для Minikube:

```bash
minikube ip
```

Затем добавьте в `/etc/hosts`:

```
<MINIKUBE_IP> snowflake.dev.local
```

### Windows

Отредактируйте файл `C:\Windows\System32\drivers\etc\hosts` (требуются права администратора):

```
127.0.0.1 snowflake.dev.local
```

## Часть 3: Применение манифестов

1. Убедитесь, что все необходимые ресурсы развернуты:

```bash
kubectl apply -f app-rs.yml
kubectl apply -f app-service.yml
kubectl apply -f app-ingress.yml
```

2. Проверьте статус Ingress:

```bash
kubectl get ingress
```

3. Проверьте детали Ingress:

```bash
kubectl describe ingress snowflake-app-ingress
```

## Часть 4: Тестирование

1. Проверьте доступность через Ingress:

```bash
curl http://snowflake.dev.local/v1/next-id
```

2. Для проверки балансировки нагрузки выполните несколько запросов:

```bash
for i in {1..10}; do curl http://snowflake.dev.local/v1/next-id; echo ""; done
```

Запросы должны распределяться между репликами Pod.

3. Проверьте логи Ingress Controller:

```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

## Устранение неполадок

### Если Ingress не работает:

1. Проверьте, что Ingress Controller запущен:
```bash
kubectl get pods -n ingress-nginx
```

2. Проверьте логи Ingress Controller:
```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

3. Проверьте, что Service существует и доступен:
```bash
kubectl get svc snowflake-app-service
kubectl get endpoints snowflake-app-service
```

4. Проверьте DNS разрешение:
```bash
ping snowflake.dev.local
nslookup snowflake.dev.local
```

### Для Minikube:

Если используете Minikube, включите Ingress addon:

```bash
minikube addons enable ingress
```

Затем получите IP адрес Minikube:

```bash
minikube ip
```

И добавьте его в `/etc/hosts`:

```
<MINIKUBE_IP> snowflake.dev.local
```


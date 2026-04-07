# Этап сборки (Build stage)
# Используется официальный образ caddy:builder, который базируется на golang:alpine
# и содержит компилятор Go и инструмент xcaddy для сборки кастомных модулей.
FROM caddy:builder AS builder

# Сборка Caddy с модулем forwardproxy (ветка naive).
# Инструмент xcaddy является специализированным сборщиком: он автоматически загружает
# исходный код ядра Caddy и указанных плагинов напрямую из репозиториев (GitHub),
# после чего выполняет компиляцию с использованием встроенного Go, избавляя от
# необходимости ручного использования git, curl или настройки окружения Go.
RUN xcaddy build \
    --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

# Этап выполнения (Final stage)
FROM caddy:latest

# Перенос бинарного файла Caddy
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Конфигурация системных директорий и прав доступа (UID 1000)
# Используются числовые ID (1000:1000) для гарантии совместимости с образом Caddy.
RUN mkdir -p /data /config /var/www/html && \
    chown -R 1000:1000 /data /config /var/www/html

# Использование непривилегированного пользователя (UID 1000)
USER 1000

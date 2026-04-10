# ============================================
# Aarogya Sathi — Frontend (Flutter Web)
# Multi-stage: Build → Serve with Nginx
# ============================================

# ── Stage 1: Flutter Web Build ──
FROM ghcr.io/cirruslabs/flutter:3.38.5 AS build

WORKDIR /app

# Copy dependency files first (cache layer)
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build Flutter web release
RUN flutter build web --release --web-renderer html

# ── Stage 2: Nginx Production Server ──
FROM nginx:alpine AS production

# Labels
LABEL maintainer="Jay-D21 <jay@aarogyasathi.dev>"
LABEL description="Aarogya Sathi Flutter Web Frontend"
LABEL version="1.0.0"

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Add custom Nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Flutter web app
COPY --from=build /app/build/web /usr/share/nginx/html

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -q --spider http://localhost:80/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# ============================================
# Aarogya Sathi — Database (PostgreSQL 15)
# Auto-initializes schema on first run
# ============================================

FROM postgres:15-alpine

# Labels
LABEL maintainer="Jay-D21 <jay@aarogyasathi.dev>"
LABEL description="Aarogya Sathi PostgreSQL Database"
LABEL version="1.0.0"

# Copy SQL init scripts (executed in alphabetical order on first run)
# PostgreSQL auto-runs .sql files from /docker-entrypoint-initdb.d/
COPY 02_types_and_domains.sql   /docker-entrypoint-initdb.d/01_types.sql
COPY 03_tables.sql              /docker-entrypoint-initdb.d/02_tables.sql
COPY 04_procedures_and_functions.sql /docker-entrypoint-initdb.d/03_procedures.sql
COPY 05_triggers.sql            /docker-entrypoint-initdb.d/04_triggers.sql
COPY 06_views_indexes_rls.sql   /docker-entrypoint-initdb.d/05_views.sql
COPY 07_seed_data.sql           /docker-entrypoint-initdb.d/06_seed.sql

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB || exit 1

EXPOSE 5432

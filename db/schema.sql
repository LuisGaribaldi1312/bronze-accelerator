-- schema.sql
-- Diseño de base de datos para CODIGO COMPANY
-- "Gestión Ambiental y Control de Plagas"
--
-- Rol: SUPERADMIN > ADMIN > SUPERVISOR > TECNICO
-- AppSheet se conecta con un usuario de permisos limitados (appsheet_user)

-- ============================================================
-- ROLES Y USUARIOS
-- ============================================================

CREATE TABLE roles (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    permissions JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (name, display_name, description, permissions) VALUES
    ('superadmin', 'SUPERADMIN', 'Acceso completo al sistema', 
     '{"dashboard":true,"clients":true,"services":true,"technicians":true,"users":true,"roles":true,"config":true,"audit":true,"financial":true,"kpi":true,"reports":true,"quotes":true,"appointments":true,"communication":true,"products":true,"pests":true,"certifications":true,"partners":true}'),
    ('admin', 'ADMIN', 'Administrador general', 
     '{"dashboard":true,"clients":true,"services":true,"technicians":true,"users":false,"roles":false,"config":true,"audit":true,"financial":true,"kpi":true,"reports":true,"quotes":true,"appointments":true,"communication":true,"products":true,"pests":true,"certifications":true,"partners":true}'),
    ('supervisor', 'SUPERVISOR', 'Supervisor de técnicos', 
     '{"dashboard":true,"clients":true,"services":true,"technicians":true,"users":false,"roles":false,"config":false,"audit":false,"financial":false,"kpi":true,"reports":false,"quotes":false,"appointments":false,"communication":true,"products":false,"pests":false,"certifications":false,"partners":false}'),
    ('technician', 'TÉCNICO', 'Técnico de campo', 
     '{"dashboard":false,"clients":false,"services":true,"technicians":false,"users":false,"roles":false,"config":false,"audit":false,"financial":false,"kpi":true,"reports":false,"quotes":false,"appointments":false,"communication":true,"products":false,"pests":false,"certifications":false,"partners":false}');

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username        VARCHAR(100) UNIQUE NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255) NOT NULL,
    phone           VARCHAR(50),
    role_id         INTEGER REFERENCES roles(id),
    employee_id     VARCHAR(50),
    technician_id   INTEGER,
    is_active       BOOLEAN DEFAULT true,
    last_login      TIMESTAMP WITH TIME ZONE,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until    TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- AUDITORÍA
-- ============================================================

CREATE TABLE audit_log (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID REFERENCES users(id),
    action      VARCHAR(100) NOT NULL,
    table_name  VARCHAR(100),
    row_id      VARCHAR(100),
    old_data    JSONB,
    new_data    JSONB,
    ip_address  INET,
    user_agent  TEXT,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user_id ON audit_log(user_id);
CREATE INDEX idx_audit_created_at ON audit_log(created_at);
CREATE INDEX idx_audit_action ON audit_log(action);

-- ============================================================
-- CONFIGURACIÓN DINÁMICA
-- ============================================================

CREATE TABLE company_info (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(255) NOT NULL DEFAULT 'CODIGO COMPANY',
    slogan          VARCHAR(255),
    email           VARCHAR(255),
    phone           VARCHAR(50),
    whatsapp        VARCHAR(50),
    address         TEXT,
    schedule        JSONB,
    logo_url        VARCHAR(500),
    favicon_url     VARCHAR(500),
    about_us        TEXT,
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE certifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    image_url       VARCHAR(500),
    is_active       BOOLEAN DEFAULT true,
    display_order   INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE partners (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    logo_url        VARCHAR(500),
    website_url     VARCHAR(500),
    is_active       BOOLEAN DEFAULT true,
    display_order   INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE social_links (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform        VARCHAR(50) NOT NULL,
    url             VARCHAR(500) NOT NULL,
    icon_class      VARCHAR(100),
    is_active       BOOLEAN DEFAULT true,
    display_order   INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- CATÁLOGOS
-- ============================================================

CREATE TABLE service_types (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN DEFAULT true,
    display_order   INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pest_types (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN DEFAULT true,
    display_order   INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE units (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(50) NOT NULL,
    abbreviation    VARCHAR(10),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id                  SERIAL PRIMARY KEY,
    commercial_name     VARCHAR(255) NOT NULL,
    active_ingredient   VARCHAR(255),
    product_type        VARCHAR(50),
    presentation        VARCHAR(255),
    unit_id             INTEGER REFERENCES units(id),
    info_technical      TEXT,
    registration_number VARCHAR(100),
    technical_sheet_url VARCHAR(500),
    safety_data_url     VARCHAR(500),
    is_active           BOOLEAN DEFAULT true,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- CLIENTES
-- ============================================================

CREATE TABLE clients (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(255) NOT NULL,
    company         VARCHAR(255),
    phone           VARCHAR(50),
    whatsapp        VARCHAR(50),
    email           VARCHAR(255),
    address         TEXT,
    client_type     VARCHAR(50),
    property_type   VARCHAR(50),
    observations    TEXT,
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clients_name ON clients(name);
CREATE INDEX idx_clients_company ON clients(company);

-- ============================================================
-- TÉCNICOS
-- ============================================================

CREATE TABLE technicians (
    id              SERIAL PRIMARY KEY,
    user_id         UUID UNIQUE REFERENCES users(id),
    full_name       VARCHAR(255) NOT NULL,
    photo_url       VARCHAR(500),
    phone           VARCHAR(50),
    email           VARCHAR(255),
    zone            VARCHAR(100),
    specialties     JSONB,
    is_active       BOOLEAN DEFAULT true,
    hire_date       DATE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_technicians_user_id ON technicians(user_id);

-- ============================================================
-- SERVICIOS
-- ============================================================

CREATE TYPE service_status_enum AS ENUM (
    'PROGRAMADO',
    'ASIGNADO',
    'CONFIRMADO',
    'EN_CAMINO',
    'EN_SITIO',
    'EN_PROCESO',
    'PENDIENTE',
    'FINALIZADO',
    'CANCELADO',
    'REPROGRAMADO',
    'CERRADO'
);

CREATE TABLE services (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id           UUID REFERENCES clients(id),
    address             TEXT NOT NULL,
    phone               VARCHAR(50),
    service_type_id     INTEGER REFERENCES service_types(id),
    pest_type_id        INTEGER REFERENCES pest_types(id),
    scheduled_date      DATE NOT NULL,
    scheduled_time      TIME NOT NULL,
    technician_id       INTEGER REFERENCES technicians(id),
    area                VARCHAR(255),
    instructions        TEXT,
    observations        TEXT,
    status              service_status_enum DEFAULT 'PROGRAMADO',
    completion_notes    TEXT,
    completion_date     TIMESTAMP WITH TIME ZONE,
    created_by          UUID REFERENCES users(id),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_services_technician ON services(technician_id);
CREATE INDEX idx_services_client ON services(client_id);
CREATE INDEX idx_services_date ON services(scheduled_date);
CREATE INDEX idx_services_status ON services(status);

CREATE TABLE service_status_history (
    id              SERIAL PRIMARY KEY,
    service_id      UUID REFERENCES services(id),
    from_status     service_status_enum,
    to_status       service_status_enum NOT NULL,
    changed_by      UUID REFERENCES users(id),
    changed_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes           TEXT
);

CREATE INDEX idx_status_history_service ON service_status_history(service_id);

CREATE TABLE service_areas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id      UUID REFERENCES services(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE service_activities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id      UUID REFERENCES services(id) ON DELETE CASCADE,
    pest_type_id    INTEGER REFERENCES pest_types(id),
    area_id         UUID REFERENCES service_areas(id),
    product_id      INTEGER REFERENCES products(id),
    quantity        DECIMAL(10,2),
    method          VARCHAR(100),
    observations    TEXT,
    technician_id   INTEGER REFERENCES technicians(id),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activities_service ON service_activities(service_id);

CREATE TABLE service_photos (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id      UUID REFERENCES services(id) ON DELETE CASCADE,
    technician_id   INTEGER REFERENCES technicians(id),
    client_id       UUID REFERENCES clients(id),
    photo_type      VARCHAR(50) CHECK (
        photo_type IN ('antes','durante','despues',
                       'evidencia_plaga','area_tratada',
                       'producto','equipo','resultado',
                       'adicional')
    ),
    photo_url       VARCHAR(500) NOT NULL,
    file_size_bytes INTEGER,
    original_name   VARCHAR(255),
    uploaded_at     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_synced       BOOLEAN DEFAULT false,
    sync_status     VARCHAR(20) DEFAULT 'pending' CHECK (
        sync_status IN ('synced','pending','syncing','error')
    )
);

CREATE INDEX idx_photos_service ON service_photos(service_id);
CREATE INDEX idx_photos_technician ON service_photos(technician_id);
CREATE INDEX idx_photos_sync_status ON service_photos(sync_status);

CREATE TABLE service_notes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id      UUID REFERENCES services(id) ON DELETE CASCADE,
    note_type       VARCHAR(50) CHECK (
        note_type IN ('observaciones','recomendaciones',
                      'incidencias','resultado','proximo_servicio')
    ),
    content         TEXT NOT NULL,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notes_service ON service_notes(service_id);

-- ============================================================
-- COMUNICACIÓN Y NOTIFICACIONES
-- ============================================================

CREATE TABLE messages (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id       UUID REFERENCES users(id),
    receiver_id     UUID REFERENCES users(id),
    service_id      UUID REFERENCES services(id),
    subject         VARCHAR(255),
    message         TEXT NOT NULL,
    is_read         BOOLEAN DEFAULT false,
    is_important    BOOLEAN DEFAULT false,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_read ON messages(is_read);

CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID REFERENCES users(id),
    type            VARCHAR(50) NOT NULL,
    title           VARCHAR(255),
    message         TEXT,
    related_id      UUID,
    related_type    VARCHAR(50),
    is_read         BOOLEAN DEFAULT false,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- ============================================================
-- COTIZACIONES Y RECORRIDOS
-- ============================================================

CREATE TABLE quotes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_name     VARCHAR(255) NOT NULL,
    company         VARCHAR(255),
    phone           VARCHAR(50),
    whatsapp        VARCHAR(50),
    email           VARCHAR(255),
    address         TEXT,
    property_type   VARCHAR(50),
    service_type    VARCHAR(100),
    pest_type       VARCHAR(100),
    description     TEXT,
    area_approximate DECIMAL(10,2),
    preferred_date  DATE,
    preferred_time  TIME,
    status          VARCHAR(20) DEFAULT 'nueva' CHECK (
        status IN ('nueva','en_revision','contactado','programada','atendida','cerrada')
    ),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE appointments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id       UUID REFERENCES clients(id),
    contact_name    VARCHAR(255) NOT NULL,
    company         VARCHAR(255),
    address         TEXT,
    phone           VARCHAR(50),
    email           VARCHAR(255),
    property_type   VARCHAR(50),
    reason          TEXT,
    requested_date  DATE NOT NULL,
    requested_time  TIME NOT NULL,
    observations    TEXT,
    status          VARCHAR(20) DEFAULT 'nueva' CHECK (
        status IN ('nueva','en_revision','contactado','programada','atendida','cerrada')
    ),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- KPIs Y SINCRRONIZACIÓN
-- ============================================================

CREATE TABLE kpi_cache (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    technician_id   INTEGER REFERENCES technicians(id),
    metric_type     VARCHAR(50) NOT NULL,
    metric_value    NUMERIC(10,2),
    period_date     DATE NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_kpi_technician ON kpi_cache(technician_id);
CREATE INDEX idx_kpi_metric ON kpi_cache(metric_type);

CREATE TABLE sync_queue (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID REFERENCES users(id),
    table_name      VARCHAR(100) NOT NULL,
    row_id          VARCHAR(100) NOT NULL,
    action          VARCHAR(20) CHECK (action IN ('INSERT','UPDATE','DELETE')),
    payload         JSONB,
    status          VARCHAR(20) DEFAULT 'pending' CHECK (
        status IN ('synced','pending','syncing','error')
    ),
    error_message   TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sync_user ON sync_queue(user_id);
CREATE INDEX idx_sync_status ON sync_queue(status);

-- ============================================================
-- RECUPERACIÓN DE CONTRASEÑA
-- ============================================================

CREATE TABLE password_reset_tokens (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID REFERENCES users(id),
    token_hash      VARCHAR(255) NOT NULL,
    expires_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    used            BOOLEAN DEFAULT false,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reset_user ON password_reset_tokens(user_id);

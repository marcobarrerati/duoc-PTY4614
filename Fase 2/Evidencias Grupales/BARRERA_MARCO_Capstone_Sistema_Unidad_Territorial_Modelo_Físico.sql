-- ============================================
-- MODELO LÓGICO - SISTEMA UNIDAD TERRITORIAL
-- Base de Datos: PostgreSQL (Supabase)
-- Autor: @marcobarrerati
-- ============================================

-- TABLA: perfiles
-- Extiende la autenticación de Supabase con información adicional
CREATE TABLE perfiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    rut VARCHAR(12) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100) NOT NULL,
    direccion TEXT,
    foto_perfil_url TEXT,
    estado VARCHAR(20) DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo', 'suspendido')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: roles
-- Define los roles del sistema
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: juntas_vecinos
-- Información de las juntas de vecinos
CREATE TABLE juntas_vecinos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    numero_junta VARCHAR(20) UNIQUE NOT NULL,
    rut_juridico VARCHAR(12) UNIQUE,
    direccion TEXT NOT NULL,
    comuna VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100),
    fecha_constitucion DATE,
    personalidad_juridica VARCHAR(50),
    logo_url TEXT,
    estado VARCHAR(20) DEFAULT 'activa' CHECK (estado IN ('activa', 'inactiva', 'disuelta')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- TABLA: usuarios_roles
-- Relación muchos a muchos entre usuarios y roles
CREATE TABLE usuarios_roles (
    id SERIAL PRIMARY KEY,
    perfil_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    rol_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    fecha_asignacion TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(perfil_id, rol_id, junta_vecinos_id)
);



-- TABLA: miembros_junta
-- Registro de vecinos miembros de la junta
CREATE TABLE miembros_junta (
    id SERIAL PRIMARY KEY,
    perfil_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    numero_socio VARCHAR(20),
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente','activo', 'inactivo', 'retirado')),
    motivo_retiro TEXT,
    fecha_retiro DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(perfil_id, junta_vecinos_id)
);

-- TABLA: historial_miembros_junta
-- Historial de cambios en el estado de los miembros de la junta
CREATE TABLE historial_miembros_junta (
    id SERIAL PRIMARY KEY,
    miembro_junta_id INTEGER REFERENCES miembros_junta(id) ON DELETE CASCADE,
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20) NOT NULL,
    motivo TEXT,
    modificado_por UUID REFERENCES perfiles(id),
    observaciones TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);



-- TABLA: directiva
-- Composición de la directiva de la junta
CREATE TABLE directiva (
    id SERIAL PRIMARY KEY,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    miembro_id INTEGER REFERENCES miembros_junta(id) ON DELETE CASCADE,
    cargo VARCHAR(50) NOT NULL CHECK (cargo IN ('presidente', 'vicepresidente', 'secretario', 'tesorero', 'director')),
    fecha_inicio DATE NOT NULL,
    fecha_termino DATE,
    estado VARCHAR(20) DEFAULT 'activo' CHECK (estado IN ('activo', 'finalizado')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: tipos_solicitud
-- Catálogo de tipos de solicitudes
CREATE TABLE tipos_solicitud (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    requiere_aprobacion BOOLEAN DEFAULT true,
    dias_procesamiento INTEGER DEFAULT 5,
    plantilla_documento TEXT,
    estado VARCHAR(20) DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: solicitudes
-- Solicitudes realizadas por los vecinos
CREATE TABLE solicitudes (
    id SERIAL PRIMARY KEY,
    tipo_solicitud_id INTEGER REFERENCES tipos_solicitud(id) ON DELETE RESTRICT,
    solicitante_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    numero_solicitud VARCHAR(50) UNIQUE NOT NULL,
    asunto VARCHAR(200) NOT NULL,
    descripcion TEXT,
    estado VARCHAR(30) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'en_revision', 'aprobada', 'rechazada', 'completada', 'cancelada')),
    fecha_solicitud TIMESTAMPTZ DEFAULT NOW(),
    fecha_revision TIMESTAMPTZ,
    fecha_resolucion TIMESTAMPTZ,
    revisado_por UUID REFERENCES perfiles(id),
    resuelto_por UUID REFERENCES perfiles(id),
    observaciones TEXT,
    documento_generado_url TEXT,
    prioridad VARCHAR(20) DEFAULT 'normal' CHECK (prioridad IN ('baja', 'normal', 'alta', 'urgente')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: seguimiento_solicitudes
-- Historial de cambios en las solicitudes
CREATE TABLE seguimiento_solicitudes (
    id SERIAL PRIMARY KEY,
    solicitud_id INTEGER REFERENCES solicitudes(id) ON DELETE CASCADE,
    usuario_id UUID REFERENCES perfiles(id),
    estado_anterior VARCHAR(30),
    estado_nuevo VARCHAR(30) NOT NULL,
    comentario TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: certificados
-- Certificados emitidos por la junta
CREATE TABLE certificados (
    id SERIAL PRIMARY KEY,
    solicitud_id INTEGER REFERENCES solicitudes(id) ON DELETE SET NULL,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    beneficiario_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    tipo_certificado VARCHAR(100) NOT NULL,
    numero_certificado VARCHAR(50) UNIQUE NOT NULL,
    contenido TEXT NOT NULL,
    fecha_emision DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_vencimiento DATE,
    emitido_por UUID REFERENCES perfiles(id),
    documento_url TEXT,
    estado VARCHAR(20) DEFAULT 'vigente' CHECK (estado IN ('vigente', 'vencido', 'anulado')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: proyectos
-- Proyectos vecinales
CREATE TABLE proyectos (
    id SERIAL PRIMARY KEY,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT NOT NULL,
    objetivo TEXT,
    propuesto_por UUID REFERENCES perfiles(id),
    fecha_inicio DATE,
    fecha_termino DATE,
    presupuesto_estimado DECIMAL(12, 2),
    presupuesto_aprobado DECIMAL(12, 2),
    fuente_financiamiento VARCHAR(100),
    estado VARCHAR(30) DEFAULT 'propuesta' CHECK (estado IN ('propuesta', 'en_evaluacion', 'aprobado', 'en_ejecucion', 'completado', 'rechazado', 'cancelado')),
    prioridad VARCHAR(20) DEFAULT 'media' CHECK (prioridad IN ('baja', 'media', 'alta')),
    categoria VARCHAR(50),
    documento_propuesta_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: hitos_proyecto
-- Hitos y avances de proyectos
CREATE TABLE hitos_proyecto (
    id SERIAL PRIMARY KEY,
    proyecto_id INTEGER REFERENCES proyectos(id) ON DELETE CASCADE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_planificada DATE,
    fecha_completada DATE,
    porcentaje_avance INTEGER DEFAULT 0 CHECK (porcentaje_avance >= 0 AND porcentaje_avance <= 100),
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'en_progreso', 'completado', 'atrasado')),
    responsable_id UUID REFERENCES perfiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: recursos_comunitarios
-- Espacios y recursos disponibles para la comunidad
CREATE TABLE recursos_comunitarios (
    id SERIAL PRIMARY KEY,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('cancha', 'salon', 'plaza', 'sede', 'equipamiento', 'otro')),
    descripcion TEXT,
    ubicacion TEXT,
    capacidad INTEGER,
    requiere_reserva BOOLEAN DEFAULT true,
    costo_uso DECIMAL(10, 2) DEFAULT 0,
    imagen_url TEXT,
    estado VARCHAR(20) DEFAULT 'disponible' CHECK (estado IN ('disponible', 'en_mantenimiento', 'no_disponible')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: reservas
-- Reservas de recursos comunitarios
CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    recurso_id INTEGER REFERENCES recursos_comunitarios(id) ON DELETE CASCADE,
    solicitante_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    fecha_reserva DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    motivo TEXT NOT NULL,
    numero_asistentes INTEGER,
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'confirmada', 'rechazada', 'cancelada', 'completada')),
    aprobada_por UUID REFERENCES perfiles(id),
    fecha_aprobacion TIMESTAMPTZ,
    observaciones TEXT,
    costo_total DECIMAL(10, 2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT check_horario CHECK (hora_fin > hora_inicio)
);

-- TABLA: actividades
-- Actividades y eventos comunitarios
CREATE TABLE actividades (
    id SERIAL PRIMARY KEY,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(50) CHECK (tipo IN ('taller', 'reunion', 'celebracion', 'deporte', 'cultural', 'educativo', 'otro')),
    fecha_inicio TIMESTAMPTZ NOT NULL,
    fecha_fin TIMESTAMPTZ NOT NULL,
    ubicacion TEXT,
    cupos_disponibles INTEGER,
    cupos_ocupados INTEGER DEFAULT 0,
    requiere_inscripcion BOOLEAN DEFAULT true,
    costo DECIMAL(10, 2) DEFAULT 0,
    imagen_url TEXT,
    organizador_id UUID REFERENCES perfiles(id),
    estado VARCHAR(20) DEFAULT 'programada' CHECK (estado IN ('programada', 'en_curso', 'finalizada', 'cancelada', 'suspendida')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT check_fecha_actividad CHECK (fecha_fin > fecha_inicio),
    CONSTRAINT check_cupos CHECK (cupos_ocupados <= cupos_disponibles)
);

-- TABLA: inscripciones_actividad
-- Inscripciones de vecinos a actividades
CREATE TABLE inscripciones_actividad (
    id SERIAL PRIMARY KEY,
    actividad_id INTEGER REFERENCES actividades(id) ON DELETE CASCADE,
    participante_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    fecha_inscripcion TIMESTAMPTZ DEFAULT NOW(),
    estado VARCHAR(20) DEFAULT 'confirmada' CHECK (estado IN ('confirmada', 'en_espera', 'cancelada', 'asistio', 'no_asistio')),
    observaciones TEXT,
    pago_realizado BOOLEAN DEFAULT false,
    UNIQUE(actividad_id, participante_id)
);

-- TABLA: categorias_noticia
-- Categorías para clasificar noticias
CREATE TABLE categorias_noticia (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    color VARCHAR(7), -- Color hex para UI
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: noticias
-- Noticias y anuncios de la junta
CREATE TABLE noticias (
    id SERIAL PRIMARY KEY,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    categoria_id INTEGER REFERENCES categorias_noticia(id) ON DELETE SET NULL,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    resumen TEXT,
    imagen_portada_url TEXT,
    autor_id UUID REFERENCES perfiles(id),
    fecha_publicacion TIMESTAMPTZ DEFAULT NOW(),
    fecha_expiracion TIMESTAMPTZ,
    es_destacada BOOLEAN DEFAULT false,
    vistas INTEGER DEFAULT 0,
    estado VARCHAR(20) DEFAULT 'publicada' CHECK (estado IN ('borrador', 'publicada', 'archivada')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: tipos_notificacion
-- Catálogo de tipos de notificaciones
CREATE TABLE tipos_notificacion (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    plantilla_titulo TEXT,
    plantilla_contenido TEXT,
    canales_permitidos TEXT[], -- array: ['email', 'sms', 'push', 'whatsapp']
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: notificaciones
-- Sistema de notificaciones
CREATE TABLE notificaciones (
    id SERIAL PRIMARY KEY,
    tipo_notificacion_id INTEGER REFERENCES tipos_notificacion(id) ON DELETE SET NULL,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    destinatario_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    canal VARCHAR(20) NOT NULL CHECK (canal IN ('email', 'sms', 'push', 'whatsapp', 'sistema')),
    prioridad VARCHAR(20) DEFAULT 'normal' CHECK (prioridad IN ('baja', 'normal', 'alta', 'urgente')),
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'enviada', 'leida', 'fallida')),
    fecha_envio TIMESTAMPTZ,
    fecha_lectura TIMESTAMPTZ,
    metadata JSONB, -- Datos adicionales flexibles
    error_mensaje TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: avisos
-- Avisos generales para la comunidad
CREATE TABLE avisos (
    id SERIAL PRIMARY KEY,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('informativo', 'urgente', 'mantenimiento', 'evento', 'otro')),
    fecha_publicacion TIMESTAMPTZ DEFAULT NOW(),
    fecha_expiracion TIMESTAMPTZ,
    publicado_por UUID REFERENCES perfiles(id),
    es_urgente BOOLEAN DEFAULT false,
    destinatarios VARCHAR(20) DEFAULT 'todos' CHECK (destinatarios IN ('todos', 'miembros', 'directiva')),
    imagen_url TEXT,
    estado VARCHAR(20) DEFAULT 'activo' CHECK (estado IN ('activo', 'vencido', 'eliminado')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: documentos
-- Repositorio de documentos
CREATE TABLE documentos (
    id SERIAL PRIMARY KEY,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    tipo_documento VARCHAR(50) CHECK (tipo_documento IN ('acta', 'reglamento', 'informe', 'certificado', 'contrato', 'otro')),
    archivo_url TEXT NOT NULL,
    archivo_nombre VARCHAR(200) NOT NULL,
    archivo_tamano BIGINT, -- tamaño en bytes
    mime_type VARCHAR(100),
    subido_por UUID REFERENCES perfiles(id),
    es_publico BOOLEAN DEFAULT false,
    fecha_documento DATE,
    version VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: comentarios
-- Sistema de comentarios para proyectos y noticias
CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    autor_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    entidad_tipo VARCHAR(20) NOT NULL CHECK (entidad_tipo IN ('proyecto', 'noticia', 'actividad')),
    entidad_id INTEGER NOT NULL,
    comentario_padre_id INTEGER REFERENCES comentarios(id) ON DELETE CASCADE,
    contenido TEXT NOT NULL,
    estado VARCHAR(20) DEFAULT 'publicado' CHECK (estado IN ('publicado', 'oculto', 'eliminado')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: auditorias
-- Registro de auditoría del sistema
CREATE TABLE auditorias (
    id SERIAL PRIMARY KEY,
    usuario_id UUID REFERENCES perfiles(id) ON DELETE SET NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100),
    registro_id INTEGER,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABLA: configuraciones
-- Configuraciones del sistema por junta
CREATE TABLE configuraciones (
    id SERIAL PRIMARY KEY,
    junta_vecinos_id INTEGER REFERENCES juntas_vecinos(id) ON DELETE CASCADE,
    clave VARCHAR(100) NOT NULL,
    valor TEXT,
    tipo_dato VARCHAR(20) CHECK (tipo_dato IN ('string', 'number', 'boolean', 'json')),
    descripcion TEXT,
    actualizado_por UUID REFERENCES perfiles(id),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(junta_vecinos_id, clave)
);

-- ============================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

CREATE INDEX idx_perfiles_rut ON perfiles(rut);
CREATE INDEX idx_perfiles_email ON perfiles(email);
CREATE INDEX idx_perfiles_estado ON perfiles(estado);

CREATE INDEX idx_miembros_junta_perfil ON miembros_junta(perfil_id);
CREATE INDEX idx_miembros_junta_junta_vecinos ON miembros_junta(junta_vecinos_id);
CREATE INDEX idx_miembros_junta_estado ON miembros_junta(estado);

CREATE INDEX idx_solicitudes_solicitante ON solicitudes(solicitante_id);
CREATE INDEX idx_solicitudes_junta_vecinos ON solicitudes(junta_vecinos_id);
CREATE INDEX idx_solicitudes_estado ON solicitudes(estado);
CREATE INDEX idx_solicitudes_fecha ON solicitudes(fecha_solicitud);

CREATE INDEX idx_proyectos_junta_vecinos ON proyectos(junta_vecinos_id);
CREATE INDEX idx_proyectos_estado ON proyectos(estado);
CREATE INDEX idx_proyectos_propuesto_por ON proyectos(propuesto_por);

CREATE INDEX idx_reservas_recurso ON reservas(recurso_id);
CREATE INDEX idx_reservas_solicitante ON reservas(solicitante_id);
CREATE INDEX idx_reservas_fecha ON reservas(fecha_reserva);
CREATE INDEX idx_reservas_estado ON reservas(estado);

CREATE INDEX idx_actividades_junta_vecinos ON actividades(junta_vecinos_id);
CREATE INDEX idx_actividades_fecha_inicio ON actividades(fecha_inicio);
CREATE INDEX idx_actividades_estado ON actividades(estado);

CREATE INDEX idx_inscripciones_actividad ON inscripciones_actividad(actividad_id);
CREATE INDEX idx_inscripciones_participante ON inscripciones_actividad(participante_id);

CREATE INDEX idx_noticias_junta_vecinos ON noticias(junta_vecinos_id);
CREATE INDEX idx_noticias_categoria ON noticias(categoria_id);
CREATE INDEX idx_noticias_estado ON noticias(estado);
CREATE INDEX idx_noticias_fecha_publicacion ON noticias(fecha_publicacion);

CREATE INDEX idx_notificaciones_destinatario ON notificaciones(destinatario_id);
CREATE INDEX idx_notificaciones_estado ON notificaciones(estado);
CREATE INDEX idx_notificaciones_fecha ON notificaciones(created_at);

CREATE INDEX idx_documentos_junta_vecinos ON documentos(junta_vecinos_id);
CREATE INDEX idx_documentos_tipo ON documentos(tipo_documento);
CREATE INDEX idx_documentos_publico ON documentos(es_publico);

CREATE INDEX idx_comentarios_entidad ON comentarios(entidad_tipo, entidad_id);
CREATE INDEX idx_comentarios_autor ON comentarios(autor_id);

CREATE INDEX idx_auditorias_usuario ON auditorias(usuario_id);
CREATE INDEX idx_auditorias_tabla ON auditorias(tabla_afectada);
CREATE INDEX idx_auditorias_fecha ON auditorias(created_at);

CREATE INDEX idx_historial_miembros_miembro ON historial_miembros_junta(miembro_junta_id);
CREATE INDEX idx_historial_miembros_fecha ON historial_miembros_junta(created_at);


-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a tablas relevantes
CREATE TRIGGER trigger_perfiles_updated_at
    BEFORE UPDATE ON perfiles
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_juntas_vecinos_updated_at
    BEFORE UPDATE ON juntas_vecinos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_miembros_junta_updated_at
    BEFORE UPDATE ON miembros_junta
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_solicitudes_updated_at
    BEFORE UPDATE ON solicitudes
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_proyectos_updated_at
    BEFORE UPDATE ON proyectos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_actividades_updated_at
    BEFORE UPDATE ON actividades
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_noticias_updated_at
    BEFORE UPDATE ON noticias
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();



-- Función para actualizar cupos ocupados en actividades
CREATE OR REPLACE FUNCTION actualizar_cupos_actividad()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' AND NEW.estado = 'confirmada') THEN
        UPDATE actividades 
        SET cupos_ocupados = cupos_ocupados + 1
        WHERE id = NEW.actividad_id;
    ELSIF (TG_OP = 'UPDATE' AND OLD.estado != 'confirmada' AND NEW.estado = 'confirmada') THEN
        UPDATE actividades 
        SET cupos_ocupados = cupos_ocupados + 1
        WHERE id = NEW.actividad_id;
    ELSIF (TG_OP = 'UPDATE' AND OLD.estado = 'confirmada' AND NEW.estado != 'confirmada') THEN
        UPDATE actividades 
        SET cupos_ocupados = cupos_ocupados - 1
        WHERE id = NEW.actividad_id;
    ELSIF (TG_OP = 'DELETE' AND OLD.estado = 'confirmada') THEN
        UPDATE actividades 
        SET cupos_ocupados = cupos_ocupados - 1
        WHERE id = OLD.actividad_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_cupos
    AFTER INSERT OR UPDATE OR DELETE ON inscripciones_actividad
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_cupos_actividad();

-- ============================================
-- DATOS INICIALES
-- ============================================

-- Insertar roles básicos
INSERT INTO roles (nombre, descripcion) VALUES
    ('superadmin', 'Administrador del sistema con acceso total'),
    ('presidente', 'Presidente de la junta de vecinos'),
    ('vicepresidente', 'Vicepresidente de la junta de vecinos'),
    ('secretario', 'Secretario de la junta de vecinos'),
    ('tesorero', 'Tesorero de la junta de vecinos'),
    ('director', 'Director de la junta de vecinos'),
    ('miembro', 'Miembro activo de la junta de vecinos'),
    ('vecino', 'Vecino registrado en el sistema');

-- Insertar categorías de noticias
INSERT INTO categorias_noticia (nombre, descripcion, color) VALUES
    ('Informativo', 'Noticias informativas generales', '#3B82F6'),
    ('Urgente', 'Avisos urgentes y de emergencia', '#EF4444'),
    ('Eventos', 'Anuncios de eventos y actividades', '#10B981'),
    ('Mantenimiento', 'Avisos de mantenimiento', '#F59E0B'),
    ('Proyectos', 'Noticias sobre proyectos comunitarios', '#8B5CF6');

-- Insertar tipos de solicitud comunes
INSERT INTO tipos_solicitud (nombre, descripcion, requiere_aprobacion, dias_procesamiento) VALUES
    ('Certificado de Residencia', 'Solicitud de certificado que acredita residencia en el sector', true, 3),
    ('Uso de Espacios Comunitarios', 'Solicitud para uso de canchas, salas o espacios comunes', true, 2),
    ('Certificado de Afiliación', 'Certificado que acredita ser miembro de la junta de vecinos', true, 2),
    ('Solicitud de Información', 'Solicitud de información general', false, 5);

-- Insertar tipos de notificación
INSERT INTO tipos_notificacion (nombre, plantilla_titulo, plantilla_contenido, canales_permitidos) VALUES
    ('Bienvenida', 'Bienvenido al Sistema Unidad Territorial', 'Has sido registrado exitosamente', ARRAY['email', 'sistema']),
    ('Solicitud Aprobada', 'Tu solicitud ha sido aprobada', 'Tu solicitud {numero_solicitud} ha sido aprobada', ARRAY['email', 'sms', 'push']),
    ('Solicitud Rechazada', 'Tu solicitud ha sido rechazada', 'Tu solicitud {numero_solicitud} ha sido rechazada', ARRAY['email', 'push']),
    ('Nueva Actividad', 'Nueva actividad disponible', 'Se ha publicado una nueva actividad: {nombre_actividad}', ARRAY['email', 'push']),
    ('Recordatorio Actividad', 'Recordatorio de actividad', 'Recordatorio: Tienes una actividad programada', ARRAY['email', 'sms', 'push']),
    ('Aviso General', 'Nuevo aviso de la junta', 'Se ha publicado un nuevo aviso', ARRAY['email', 'push']);



-- ============================================
-- TRIGGER: CREACIÓN AUTOMÁTICA DE PERFIL AL REGISTRAR USUARIO EN AUTH.USERS
-- ============================================
-- CREAR PERFIL 
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.perfiles (
    id,
    rut,
    nombres,
    apellido_paterno,
    apellido_materno,
    fecha_nacimiento, 
    email, 
    foto_perfil_url
  )
  VALUES (
    NEW.id,
    (SELECT CAST(COUNT(*) + 1 AS TEXT) FROM public.perfiles),
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NOW(),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Trigger para ejecutar la función
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();






--
--
-- TRIGGER: HISTORIAL DE CAMBIOS EN MIEMBROS_JUNTA
-- ============================================
--
-- Función y trigger para registrar cambios de estado en miembros_junta
CREATE OR REPLACE FUNCTION registrar_cambio_estado_miembro()
RETURNS TRIGGER AS $$
DECLARE
    usuario_actual UUID;
BEGIN
    -- Obtener el usuario autenticado de Supabase
    usuario_actual := auth.uid();

    IF (TG_OP = 'UPDATE' AND OLD.estado IS DISTINCT FROM NEW.estado) THEN
        INSERT INTO historial_miembros_junta (
            miembro_junta_id,
            estado_anterior,
            estado_nuevo,
            motivo,
            modificado_por,
            observaciones
        ) VALUES (
            NEW.id,
            OLD.estado,
            NEW.estado,
            NEW.motivo_retiro,
            usuario_actual,
            'Cambio automático de estado'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trigger_historial_miembros
    AFTER UPDATE ON miembros_junta
    FOR EACH ROW
    EXECUTE FUNCTION registrar_cambio_estado_miembro();

--
--
-- 
-- ============================================
-- TRIGGER: SINCRONIZACIÓN DIRECTIVA → USUARIOS_ROLES
-- ============================================
--
-- Función: Sincronizar roles cuando cambia la directiva
CREATE OR REPLACE FUNCTION sincronizar_rol_directiva()
RETURNS TRIGGER AS $$
DECLARE
    v_perfil_id UUID;
    v_rol_id INTEGER;
BEGIN
    -- Obtener perfil_id del miembro
    SELECT perfil_id INTO v_perfil_id
    FROM miembros_junta
    WHERE id = NEW.miembro_id;
    
    -- Obtener rol_id correspondiente al cargo
    SELECT id INTO v_rol_id
    FROM roles
    WHERE nombre = NEW.cargo;
    
    -- Validar que existan los datos
    IF v_perfil_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró el perfil del miembro con id %', NEW.miembro_id;
    END IF;
    
    IF v_rol_id IS NULL THEN
        RAISE EXCEPTION 'No existe el rol % en la tabla roles', NEW.cargo;
    END IF;
    
    -- CASO 1: INSERT - Asignar nuevo cargo en directiva
    IF (TG_OP = 'INSERT' AND NEW.estado = 'activo') THEN
        -- Crear o actualizar rol en usuarios_roles
        INSERT INTO usuarios_roles (perfil_id, rol_id, junta_vecinos_id, fecha_asignacion)
        VALUES (v_perfil_id, v_rol_id, NEW.junta_vecinos_id, NEW.fecha_inicio)
        ON CONFLICT (perfil_id, rol_id, junta_vecinos_id) 
        DO UPDATE SET fecha_asignacion = NEW.fecha_inicio;
        
        RAISE NOTICE 'Rol % asignado a perfil % en junta %', NEW.cargo, v_perfil_id, NEW.junta_vecinos_id;
    
    -- CASO 2: UPDATE - Cambio de estado activo → finalizado
    ELSIF (TG_OP = 'UPDATE' AND OLD.estado = 'activo' AND NEW.estado = 'finalizado') THEN
        -- Eliminar rol cuando termina el periodo
        DELETE FROM usuarios_roles
        WHERE perfil_id = v_perfil_id
        AND rol_id = v_rol_id
        AND junta_vecinos_id = NEW.junta_vecinos_id;
        
        RAISE NOTICE 'Rol % removido de perfil % en junta %', NEW.cargo, v_perfil_id, NEW.junta_vecinos_id;
    
    -- CASO 3: UPDATE - Cambio de estado finalizado → activo (reactivación)
    ELSIF (TG_OP = 'UPDATE' AND OLD.estado = 'finalizado' AND NEW.estado = 'activo') THEN
        -- Volver a crear el rol
        INSERT INTO usuarios_roles (perfil_id, rol_id, junta_vecinos_id, fecha_asignacion)
        VALUES (v_perfil_id, v_rol_id, NEW.junta_vecinos_id, NEW.fecha_inicio)
        ON CONFLICT (perfil_id, rol_id, junta_vecinos_id) 
        DO UPDATE SET fecha_asignacion = NEW.fecha_inicio;
        
        RAISE NOTICE 'Rol % reactivado para perfil % en junta %', NEW.cargo, v_perfil_id, NEW.junta_vecinos_id;
    
    -- CASO 4: UPDATE - Cambio de cargo (ej: de secretario a presidente)
    ELSIF (TG_OP = 'UPDATE' AND OLD.cargo != NEW.cargo AND NEW.estado = 'activo') THEN
        DECLARE
            v_old_rol_id INTEGER;
        BEGIN
            -- Obtener el rol anterior
            SELECT id INTO v_old_rol_id
            FROM roles
            WHERE nombre = OLD.cargo;
            
            -- Eliminar el rol anterior
            DELETE FROM usuarios_roles
            WHERE perfil_id = v_perfil_id
            AND rol_id = v_old_rol_id
            AND junta_vecinos_id = NEW.junta_vecinos_id;
            
            -- Crear el nuevo rol
            INSERT INTO usuarios_roles (perfil_id, rol_id, junta_vecinos_id, fecha_asignacion)
            VALUES (v_perfil_id, v_rol_id, NEW.junta_vecinos_id, NOW())
            ON CONFLICT (perfil_id, rol_id, junta_vecinos_id) 
            DO UPDATE SET fecha_asignacion = NOW();
            
            RAISE NOTICE 'Cambio de cargo: % → % para perfil % en junta %', 
                OLD.cargo, NEW.cargo, v_perfil_id, NEW.junta_vecinos_id;
        END;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
CREATE TRIGGER trigger_sincronizar_rol_directiva
    AFTER INSERT OR UPDATE ON directiva
    FOR EACH ROW
    EXECUTE FUNCTION sincronizar_rol_directiva();

-- ============================================
-- TRIGGER ADICIONAL: LIMPIAR ROLES AL ELIMINAR DIRECTIVA
-- ============================================

CREATE OR REPLACE FUNCTION limpiar_rol_directiva_eliminada()
RETURNS TRIGGER AS $$
DECLARE
    v_perfil_id UUID;
    v_rol_id INTEGER;
BEGIN
    -- Obtener perfil_id del miembro
    SELECT perfil_id INTO v_perfil_id
    FROM miembros_junta
    WHERE id = OLD.miembro_id;
    
    -- Obtener rol_id correspondiente al cargo
    SELECT id INTO v_rol_id
    FROM roles
    WHERE nombre = OLD.cargo;
    
    -- Eliminar rol de usuarios_roles
    DELETE FROM usuarios_roles
    WHERE perfil_id = v_perfil_id
    AND rol_id = v_rol_id
    AND junta_vecinos_id = OLD.junta_vecinos_id;
    
    RAISE NOTICE 'Rol % eliminado de perfil % en junta % (directiva eliminada)', 
        OLD.cargo, v_perfil_id, OLD.junta_vecinos_id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_limpiar_rol_directiva
    AFTER DELETE ON directiva
    FOR EACH ROW
    EXECUTE FUNCTION limpiar_rol_directiva_eliminada();

-- ============================================
-- ÍNDICE ADICIONAL PARA OPTIMIZACIÓN
-- ============================================

CREATE INDEX IF NOT EXISTS idx_directiva_miembro_cargo_estado 
ON directiva(miembro_id, cargo, estado);

-- ============================================
-- SCRIPT DE VERIFICACIÓN
-- ============================================

-- Ver los triggers creados
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'directiva'
ORDER BY trigger_name;

-- Función para verificar sincronización
CREATE OR REPLACE FUNCTION verificar_sincronizacion_directiva()
RETURNS TABLE (
    perfil_nombre TEXT,
    cargo VARCHAR(50),
    junta_nombre VARCHAR(200),
    estado_directiva VARCHAR(20),
    tiene_rol_sistema BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.nombres || ' ' || p.apellido_paterno AS perfil_nombre,
        d.cargo,
        jv.nombre AS junta_nombre,
        d.estado AS estado_directiva,
        EXISTS (
            SELECT 1 FROM usuarios_roles ur
            JOIN roles r ON ur.rol_id = r.id
            WHERE ur.perfil_id = mj.perfil_id
            AND r.nombre = d.cargo
            AND ur.junta_vecinos_id = d.junta_vecinos_id
        ) AS tiene_rol_sistema
    FROM directiva d
    JOIN miembros_junta mj ON d.miembro_id = mj.id
    JOIN perfiles p ON mj.perfil_id = p.id
    JOIN juntas_vecinos jv ON d.junta_vecinos_id = jv.id
    ORDER BY jv.nombre, d.cargo;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar verificación
-- SELECT * FROM verificar_sincronizacion_directiva();
-- INSERT INTO directiva (junta_vecinos_id, miembro_id, cargo, fecha_inicio, estado) VALUES (1, 13, 'presidente', '2025-11-02', 'activo');
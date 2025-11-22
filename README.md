# Sistema de Gestión de Unidades Territoriales

**PTY4614 - Proyecto Capstone**

## Descripción del Proyecto

Sistema web integral para la gestión administrativa de unidades territoriales (juntas de vecinos), desarrollado como proyecto de título. La plataforma facilita la administración de vecinos, solicitudes, actividades y comunicaciones, optimizando los procesos internos de las organizaciones vecinales.

## 🎯 Objetivos

- Digitalizar la gestión administrativa de unidades territoriales
- Mejorar la comunicación entre dirigentes y vecinos
- Centralizar información de socios, solicitudes y actividades
- Facilitar el acceso a servicios mediante una interfaz moderna y responsive

## 🚀 Demo

Aplicación en producción: [https://sistema-unidad-territorial.vercel.app/login](https://sistema-unidad-territorial.vercel.app/login)

## 📋 Fases del Proyecto

| Fase                             | Descripción                   | Documentación                          |
| -------------------------------- | ----------------------------- | -------------------------------------- |
| **[Fase 1](Fase%201/README.md)** | Análisis y diseño del sistema | Evidencias de planificación y análisis |
| **[Fase 2](Fase%202/README.md)** | Desarrollo de base de datos   | Modelo físico y lógico                 |
| **[Fase 3](Fase%203/README.md)** | Implementación y despliegue   | Código fuente y documentación técnica  |

## 🏗️ Arquitectura

El sistema implementa una arquitectura moderna de tres capas:

- **Frontend**: React 18 + Vite + TypeScript + Tailwind CSS
- **Backend**: Supabase
- **Base de Datos**: PostgreSQL + Supabase
- **Infraestructura**: Vercel (Frontend) + Railway (Backend)

Consulte la [documentación de arquitectura C4](arquitectura/Especificaciones_Arquitectura_C4.md) para más detalles.

## 🛠️ Tecnologías Principales

### Frontend
- React 18.3 con TypeScript
- Vite como bundler
- shadcn/ui + Radix UI para componentes
- TailwindCSS para estilos
- React Router para navegación
- React Hook Form + Zod para formularios

### Backend
- Supabase (BaaS)
- PostgreSQL
- Autenticación OAuth

### Servicios Externos
- SendGrid (Email)
- Twilio (SMS)
- Google Maps API (Geolocalización)

## 📁 Estructura del Repositorio

```
capstone/
├── arquitectura/          # Diagramas C4 y especificaciones técnicas
├── Fase 1/                # Evidencias fase de análisis
├── Fase 2/                # Evidencias fase de desarrollo
├── Fase 3/                # Evidencias fase de implementación
└── README.md
```

## 📚 Documentación Adicional

- [Especificaciones OAuth](arquitectura/Especificaciones_Técnicas-Módulo_Autenticación_OAuth.md)
- [Especificaciones Módulo Vecinos](arquitectura/Especificaciones_Técnicas-Módulo_Vecinos.md)
- [Especigicaciones de Arquitectura](arquitectura/Especificaciones_Arquitectura_C4.md)


## 👥 Roles de Usuario

El sistema contempla tres tipos de usuarios:

1. **Vecinos**: Acceso a información personal y solicitudes
2. **Dirigentes**: Gestión de socios y actividades
3. **Administradores**: Control total del sistema

## 🔐 Seguridad

- Autenticación mediante Supabase Auth y Google OAuth
- Control de acceso basado en roles (RBAC)
- Rutas protegidas en frontend y backend
- Validación de datos con Zod

## 📄 Licencia

Este proyecto está bajo la [Licencia MIT](LICENSE).


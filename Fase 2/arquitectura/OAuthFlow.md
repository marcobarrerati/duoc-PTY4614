[volver](Especificaciones_Técnicas-Módulo_Autenticación_OAuth.md)

# Diagrama de Secuencia OAuth

## Flujo de autenticación: React + Vite + Supabase + Google OAuth + Vercel

```mermaid
sequenceDiagram
    participant U as Usuario
    participant V as Vercel App<br/>(React + Vite)
    participant S as Supabase Auth
    participant G as Google OAuth
    participant DB as Supabase DB

    Note over U,DB: 🔐 Flujo completo de autenticación OAuth

    activate U
    
    U->>V: 1. Visita la aplicación
    activate V
    V->>U: 2. Muestra página de login
    
    U->>V: 3. Click "Login con Google"
    V->>S: 4. signInWithOAuth({provider: 'google'})
    activate S
    
    Note over V,S: redirectTo configurado desde<br/>Supabase Dashboard
    
    S->>G: 5. Redirect a Google OAuth<br/>(con client_id y scopes)
    activate G
    deactivate V
    
    G->>U: 6. Muestra pantalla de consent de Google
    U->>G: 7. Autoriza permisos y se autentica
    
    G->>S: 8. Callback con authorization_code
    deactivate G
    
    S->>G: 9. Intercambia code por access_token
    activate G
    G->>S: 10. Retorna access_token + user_info
    deactivate G
    
    S->>DB: 11. Crear/actualizar usuario en auth.users
    activate DB
    DB->>S: 12. Usuario guardado/actualizado
    deactivate DB
    
    Note over S: Genera JWT session token<br/>con user metadata
    
    S->>V: 13. Redirect a Vercel app con session tokens<br/>(via URL hash/fragments)
    activate V
    deactivate S
    
    V->>V: 14. onAuthStateChange detecta tokens
    V->>S: 15. getSession() para validar
    activate S
    S->>V: 16. Retorna session válida + user data
    deactivate S
    
    V->>U: 17. Muestra dashboard/app autenticada
    
    Note over U,V: ✅ Usuario logueado exitosamente

    alt Operaciones posteriores
        U->>V: 18. Realizar acciones en la app
        V->>S: 19. API calls con JWT automático
        activate S
        S->>DB: 20. Query con Row Level Security
        activate DB
        
        Note over DB: RLS policies verifican<br/>auth.uid() = user.id
        
        DB->>S: 21. Datos filtrados por usuario
        deactivate DB
        S->>V: 22. Response con datos autorizados
        deactivate S
        V->>U: 23. Muestra datos del usuario
    end
    
    alt Logout
        U->>V: 24. Click "Cerrar sesión"
        V->>S: 25. signOut()
        activate S
        S->>S: 26. Invalida tokens
        S->>V: 27. Session terminada
        deactivate S
        V->>U: 28. Redirect a login
    end
    
    deactivate V
    deactivate U
```

## Componentes de la Arquitectura

### 🌐 **Frontend (Vercel)**
- **React + Vite**: Aplicación SPA con bundler moderno
- **Variables de entorno**: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`
- **Despliegue**: Vercel con CI/CD automático desde Git

### 🔐 **Supabase Auth**
- **OAuth Provider**: Intermediario entre Google y nuestra app
- **JWT Generation**: Crea tokens seguros con metadata del usuario
- **Session Management**: Maneja refresh tokens automáticamente

### 🔍 **Google OAuth 2.0**
- **Identity Provider**: Valida credenciales del usuario
- **Scope**: `openid profile email` para obtener info básica
- **Security**: PKCE flow para aplicaciones SPA

### 💾 **Supabase Database**
- **PostgreSQL**: Base de datos con extensiones de auth
- **Row Level Security**: Políticas a nivel de fila
- **Real-time**: Subscripciones en tiempo real (opcional)

## Configuración Requerida

### En Supabase Dashboard
```
Authentication → Settings:
├── Site URL: https://my-app-vite-01.vercel.app
├── Redirect URLs:
│   └── https://my-app-vite-01.vercel.app
└── Google OAuth:
    ├── Client ID: [desde Google Cloud Console]
    └── Client Secret: [desde Google Cloud Console]
```

### En Google Cloud Console
```
APIs & Services → Credentials → OAuth 2.0 Client:
└── Authorized redirect URIs:
    └── https://[proyecto].supabase.co/auth/v1/callback
```

### En Vercel
```
Environment Variables:
├── VITE_SUPABASE_URL=https://[proyecto].supabase.co
└── VITE_SUPABASE_ANON_KEY=eyJ[token]...
```

## Notas Importantes

- 🔑 **Seguridad**: Las variables `VITE_*` son públicas por diseño
- 🛡️ **Protección**: La seguridad real está en RLS policies
- 🔄 **Redirects**: Supabase Dashboard controla las redirecciones
- ⚡ **Performance**: JWT tokens se manejan automáticamente
- 🌍 **Ambientes**: Misma configuración para dev y prod
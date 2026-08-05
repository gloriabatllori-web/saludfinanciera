# Salud Financiera

Landing page + mini-app de educación financiera para mujeres (taller presencial de Gloria). Sitio en español, una sola página.

## Objetivo del proyecto

Es el sitio web del negocio de Gloria: imparte un **taller presencial de educación financiera para mujeres** ("vidas complejas" — hijos, familia, trabajo — que gestionan el dinero de todos menos el suyo). La web tiene tres trabajos:

1. **Captar** — la home vende la idea de que el problema no es falta de voluntad sino falta de mapa, y segmenta a la visitante en dos perfiles (Perfil 1: tiene ahorros parados, no sabe qué hacer con ellos / Perfil 2: tiene un gap de jubilación y necesita un plan) para dirigirla al contenido relevante.
2. **Educar gratis, sin vender nada** — contenido abierto (los 4 pilares: ahorro → imprevistos → futuro → inversión, preguntas frecuentes, curiosidades fiscales/de producto) y el simulador de jubilación, todo de acceso libre sin registro. Es intencionadamente **educación, no asesoramiento financiero** — el tono evita recomendar productos concretos.
3. **Dar servicio a quien ya pasó por el taller presencial** — dos zonas con acceso restringido:
   - **Zona de socias** (requiere cuenta): sesiones, materiales, ejercicios, grupo de WhatsApp — para quien se registra online.
   - **Zona privada** (requiere código personal que Gloria entrega en mano): espacio individual para reflexiones semanales y preguntas directas a Gloria, seguimiento de la evolución de cada participante.

El registro/login (Supabase) existe para que cada participante guarde sus propios números del simulador y sus reflexiones de forma persistente y privada entre sesiones — antes de conectar Supabase, todo esto vivía solo en el `localStorage` del navegador (se perdía al cambiar de dispositivo o borrar caché).

## Qué es

Página única (`index.html`, vanilla HTML/CSS/JS, sin build ni framework) con:
- Contenido educativo (los 4 pilares, temas, FAQ)
- Un simulador de jubilación en tiempo real (cálculo de gap, capital objetivo, aportación mensual)
- Registro/login real de usuarias (Supabase Auth)
- Zona de "socias" (contenido del taller, gate por login)
- Zona privada por código personal (gate independiente del login, usa `CODES` hardcodeado en el JS — no tiene relación con Supabase)

## Stack

- **Frontend**: un solo `index.html`, sin build step. Se puede abrir directo o servir con `python3 -m http.server`.
- **Backend**: Supabase (proyecto `ivghraxynsgdeohzufgb`)
  - Auth: email/password real vía `supabase-js` (CDN, `@supabase/supabase-js@2`)
  - DB: Postgres con RLS, dos tablas — ver [supabase/schema.sql](supabase/schema.sql)
    - `profiles` (user_id, gap_mensual, capital_objetivo, aportacion_mensual) — números del simulador
    - `reflexiones` (user_id, text, created_at) — reflexiones de la zona privada
  - Ambas tablas con RLS: cada usuaria solo ve/edita sus propias filas
  - El cliente de Supabase (URL + anon key) está hardcodeado directamente en `index.html` — es normal y seguro, la anon key es pública por diseño
- **Hosting**: Vercel, despliegue automático en cada push a `main`
  - URL producción: https://saludfinanciera-sooty.vercel.app
  - No hay build command — es estático, Vercel lo sirve tal cual
- **Repo**: `git@github.com:gloriabatllori-web/saludfinanciera.git` (remoto configurado por SSH, clave en `~/.ssh/id_ed25519`)

## Cosas a tener en cuenta

- **Supabase Auth → URL Configuration → Site URL** debe apuntar a `https://saludfinanciera-sooty.vercel.app` (no a localhost). Si esto se resetea o cambia el dominio de Vercel, los enlaces de confirmación de email se rompen (llevan a localhost y dan `ERR_CONNECTION_REFUSED`) — aunque ojo, la cuenta **sí queda confirmada igualmente** en el servidor de Supabase, solo falla la redirección final visual.
- `savePregunta()` (el formulario "Pregunta para Gloria") es solo un toast de UI — no persiste en ningún sitio todavía. Quedó fuera de alcance cuando se conectó Supabase (solo se pidió auth + perfil + reflexiones).
- Cuentas de prueba creadas durante QA (usando el alias `+algo` del email de Gloria, así que llegan a su propia bandeja): `gloriabatllori+supabasetest1@gmail.com`, `+supabaselive1@gmail.com`, `+supabasetest2@gmail.com`. Se pueden borrar desde Supabase → Authentication → Users si se quiere limpiar.

## Flujo de cambios

1. Editar `index.html` (o `supabase/schema.sql` si cambian las tablas)
2. Probar en local: `python3 -m http.server` en la carpeta del repo
3. Si cambia el esquema de DB, correr el SQL nuevo manualmente en el SQL Editor de Supabase (no hay migraciones automatizadas)
4. Commit + push a `main` → Vercel redespliega solo

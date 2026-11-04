# BugTrack Pro



BugTrack Pro combines bug management with a safe, evidence-based automated analyzer.



## Run locally



Install JavaScript dependencies:



```powershell

npm install

```



Install Flask and analyzer test dependencies:



```powershell

python -m pip install -r backend\requirements.txt

```



Start all services:



```powershell

npm run dev

```



Open `http://localhost:5173`. The React app runs on port 5173, the existing management API on port 3000, and the Flask analyzer on port 5000.



## Deploy on Render



This project can run as one Render web service. Create a new **Web Service** from

the repository and use:



- **Build command:** `npm ci && pip install -r backend/requirements.txt && npm run build`

- **Start command:** `npm run start:prod`

- **Health check path:** `/api/health`



Add the variables from your local `.env` in Render's Environment settings. Do not

commit `.env`; enter SMTP credentials, `EMAIL_VERIFICATION_SECRET`, and any API

keys directly in the hosting provider. Also set:



```text

APP_URL=https://your-service.onrender.com

CORS_ORIGINS=https://your-service.onrender.com

```



The service uses the host-provided `PORT` and starts the analyzer on an internal

port. If you use a separate analyzer service instead, set `ANALYZER_URL` on the

Node service to that service's private URL.



The default JSON and SQLite files are local files. Attach persistent storage (or

move these data stores to a managed database/object store) before relying on

the deployment for production data; otherwise a service restart or redeploy can

lose uploaded files and application data.



## Deploy on Vercel

Vercel runs the Vite frontend and Express API through the `api/index.js`
serverless entry point. Import the repository as a Vercel project and use the
settings from `vercel.json`:

- **Build command:** `npm run build`
- **Output directory:** `dist`
- **Install command:** `npm ci`

The Flask analyzer is deployed in the same Vercel project as the Python
function `api/analyzer.py`. The Express API forwards analyzer requests through
the internal `/api/analyzer-service/*` route. Set `ANALYZER_URL` only when
using a separately hosted analyzer; otherwise Vercel uses its own deployment
URL automatically.

Set `APP_URL`, `FRONTEND_URL`, and `CORS_ORIGINS` to the Vercel deployment URL.
Set Supabase, email, LLM, and session secrets in Vercel's Environment
settings; never commit `.env` or copy real credentials into source files.

Vercel function storage is temporary. The local JSON database, SQLite analyzer
database, uploads, and workspaces are not durable. Use Supabase and object
storage before relying on this deployment for production data. Set
`ANALYZER_DATA_DIR=/tmp/bugtrack-analyzer` if you want to make the analyzer's
temporary storage location explicit.

## Run Analyzer Tests

Run analyzer tests with pytest:



```powershell

python -m pytest backend\tests -q

```



## Automated Bug Analyzer



Open **Automated Bug Analyzer** from the sidebar. Supported evidence includes:



- Bug reports, reproduction steps, expected and actual behavior

- Error logs and stack traces

- Python, JavaScript, TypeScript, Java, JSON, HTML, CSS, TXT, and LOG files

- ZIP projects with validated archive paths

- Screenshots (stored as evidence; image-only evidence cannot confirm source-level defects)



The built-in analysis never executes submitted code. It supports Python, JavaScript/TypeScript, HTML, CSS, and Java source with language-specific static checks: Python AST parsing, Node `--check` syntax validation for JavaScript, safe JavaScript security/unused-variable patterns, HTML accessibility and form checks, CSS syntax/responsive checks, and Java brace/debug-output checks. Uploaded files are analyzed by their extensions (including mixed-language uploads); pasted source uses the selected language. Results are explicitly labeled `BUGS FOUND`, `NO BUGS DETECTED`, or `ANALYSIS INCOMPLETE`; a clean result only means that no issue was found by the configured checks and does not guarantee that code is bug-free. Findings include severity, file and line where available, evidence, explanation, and proposed fixes. Analysis history is stored in `backend\data\analyzer.sqlite3`, and temporary workspaces are kept under `backend\data\workspaces`.



The sample file at `backend\samples\broken_example.py` demonstrates a confirmed unsafe `eval()` finding.



## Email verification



New registrations remain inactive until the six-digit email verification code is confirmed. Configure SMTP only on the backend, never in frontend code:



```powershell

SMTP_HOST=smtp.gmail.com

SMTP_PORT=587

SMTP_SECURE=false

SMTP_USER=your-sender@gmail.com

SMTP_EMAIL=your-sender@gmail.com

SMTP_PASSWORD=your-gmail-app-password

SMTP_FROM_EMAIL=your-sender@gmail.com

EMAIL_VERIFICATION_EXPIRY_MINUTES=10

EMAIL_VERIFICATION_SECRET=generate-a-long-random-secret

SESSION_SECRET=generate-a-long-random-session-secret

PASSWORD_RESET_EXPIRY_MINUTES=20

APP_URL=http://localhost:5173

# Optional comma-separated browser origins allowed to call the API directly.

CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173

```



For Gmail, use an App Password rather than the normal account password. `SMTP_USER` and `SMTP_FROM_EMAIL` are preferred; the legacy `SMTP_EMAIL` variable remains supported. Use `SMTP_SECURE=true` with port 465 and `SMTP_SECURE=false` with port 587. If SMTP is not configured or delivery fails, registration returns an explicit error and does not create an account. Existing demo accounts are treated as verified; new users cannot sign in until verification succeeds.

For production deployments using Resend, configure the following backend-only variables:

```text
RESEND_API_KEY=re_...
RESEND_FROM_EMAIL=BugTrack Pro <support@your-verified-domain.example>
APP_URL=https://your-frontend.example
FRONTEND_URL=https://your-frontend.example
PASSWORD_RESET_EXPIRY_MINUTES=20
```

The sender domain must be verified in Resend. The API records a reset as accepted only after Resend returns a message ID, logs only a masked recipient, and performs a provider status lookup so bounced or suppressed addresses are visible in server logs. Never put `RESEND_API_KEY` in frontend/Vite variables or commit it to source control.



## User data isolation



Each user receives a stable unique ID at registration (and existing users are migrated once). Successful login creates a signed, expiring HTTP-only session cookie that works across serverless instances. Set a stable `SESSION_SECRET` in deployment environments; changing it signs out existing sessions. Bug reports, test cases, analysis integrations, comments, activity, dashboard statistics, exports, and execution history are assigned to and filtered by that authenticated user ID on the backend. Legacy records without an owner are quarantined from normal user views rather than being shown to every account. Logging out clears the session cookie and user-specific frontend state.



Password reset requests use a cryptographically random, single-use token stored only as a hash on the matching user record. Tokens expire after the configured `PASSWORD_RESET_EXPIRY_MINUTES` window and reset requests are rate limited. Only verified accounts can request a password reset. Set `APP_URL` or `FRONTEND_URL` to the public frontend URL so reset emails point to the deployed application. Reset requests return the same confirmation for registered and unregistered addresses.



## Fixes and verification



**Generate fix** creates a reviewable proposal. No uploaded original is overwritten. The original and proposed code are shown side by side and the proposal can be copied or downloaded. Verification reports the checks that were actually performed and clearly marks incomplete verification. Static analysis does not execute uploads or claim that every logical bug can be detected automatically.



An optional LLM provider can be configured later through environment variables in `.env.example`; secrets must remain server-side.

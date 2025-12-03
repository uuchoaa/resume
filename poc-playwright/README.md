# POC: LinkedIn Scraper com Playwright

Prova de conceito para scraping do LinkedIn usando Playwright com cookies autenticados exportados do Chrome.

## Instalação

```bash
cd poc-playwright
npm install
npx playwright install chromium
```

## Como Exportar Cookies do Chrome

### Passo 1: Login no LinkedIn
1. Abra o Chrome e faça login no [LinkedIn](https://www.linkedin.com)
2. Certifique-se de estar completamente autenticado

### Passo 2: Abrir DevTools
1. Pressione **F12** (ou **Cmd+Option+I** no Mac)
2. Vá para a aba **Application** (ou **Aplicativo**)
3. No menu lateral esquerdo, expanda **Cookies**
4. Clique em `https://www.linkedin.com`

### Passo 3: Copiar Cookies Importantes
Você precisa dos seguintes cookies:
- **li_at** (cookie principal de autenticação)
- **JSESSIONID** (sessão)

Para cada cookie:
1. Clique no nome do cookie na lista
2. Copie o valor que aparece no campo "Value"

### Passo 4: Criar arquivo cookies.json

Crie um arquivo `cookies.json` na raiz do projeto com o seguinte formato:

```json
[
  {
    "name": "li_at",
    "value": "COLE_O_VALOR_DO_LI_AT_AQUI",
    "domain": ".linkedin.com",
    "path": "/",
    "httpOnly": true,
    "secure": true,
    "sameSite": "None"
  },
  {
    "name": "JSESSIONID",
    "value": "COLE_O_VALOR_DO_JSESSIONID_AQUI",
    "domain": ".linkedin.com",
    "path": "/",
    "httpOnly": true,
    "secure": true,
    "sameSite": "None"
  }
]
```

**Importante:** O arquivo `cookies.json` está no `.gitignore` e não será commitado.

### Método Alternativo: Usar Extensão

Se preferir, use a extensão [Cookie-Editor](https://chrome.google.com/webstore/detail/cookie-editor) para exportar todos os cookies automaticamente em formato JSON.

## Uso

### Ler Mensagens de um Chat

```bash
node read-chat.js "https://www.linkedin.com/messaging/thread/2-XXXXX"

# Ver logs detalhados do browser console
DEBUG=1 node read-chat.js "https://www.linkedin.com/messaging/thread/2-XXXXX"

# Rodar com browser visível para debugging
HEADLESS=false node read-chat.js "https://www.linkedin.com/messaging/thread/2-XXXXX"
```

Saída: JSON com informações do contato e todas as mensagens do chat.

```json
{
  "success": true,
  "contact": {
    "name": "Nome da Pessoa",
    "profileUrl": "...",
    "headline": "Título profissional"
  },
  "totalMessages": 15,
  "messages": [
    {
      "sender": "Você",
      "text": "Olá, tudo bem?",
      "time": "10:30 AM"
    }
  ]
}
```

### Escrever Mensagem em um Chat

```bash
node write-chat.js "https://www.linkedin.com/messaging/thread/2-XXXXX" "Sua mensagem aqui"
```

**Nota:** O script apenas **injeta** o texto no campo de mensagem, mas **NÃO envia automaticamente**. Isso permite que você revise antes de enviar.

## Exemplos

```bash
# Ler todas as mensagens de uma conversa
node read-chat.js "https://www.linkedin.com/messaging/thread/2-YzA4MDIzMDYtMTE0ZC00"

# Escrever uma mensagem (não envia automaticamente)
node write-chat.js "https://www.linkedin.com/messaging/thread/2-YzA4MDIzMDYtMTE0ZC00" "Olá! Como vai?"

# Ver o browser em ação (modo não-headless)
HEADLESS=false node read-chat.js "https://..."
```

## Limitações

- ⚠️ **Cookies expiram**: Você precisará re-exportar cookies periodicamente (geralmente a cada 30 dias)
- ⚠️ **Rate limiting**: LinkedIn pode bloquear se fizer muitas requisições rápidas
- ⚠️ **Seletores CSS**: Podem mudar se o LinkedIn atualizar o layout
- ⚠️ **Detecção de bot**: LinkedIn pode detectar comportamento automatizado

## Próximos Passos

1. ✅ Validar que extração e injeção funcionam corretamente
2. 🔄 Criar API REST para controlar os scripts remotamente
3. 🔄 Adicionar suporte para múltiplas sessões simultâneas
4. 🔄 Implementar retry logic e tratamento de erros
5. 🔄 Adicionar rate limiting inteligente
6. 🔄 Criar processadores (summarize, export, etc)

## Troubleshooting

### "Cookies not found"
- Verifique se o arquivo `cookies.json` existe e está no formato correto
- Confirme que copiou os valores dos cookies corretamente

### "Login required" ou redirecionamento para login
- Seus cookies expiraram, exporte novamente
- Verifique se copiou os cookies corretos (`li_at` e `JSESSIONID`)

### Timeout ou página não carrega
- Aumente o timeout nos scripts (padrão: 30s)
- Verifique sua conexão com internet
- LinkedIn pode estar lento ou instável

### Script não encontra elementos
- LinkedIn pode ter mudado os seletores CSS
- Abra o LinkedIn manualmente e inspecione os elementos atuais
- Atualize os seletores nos scripts conforme necessário

## Debugging

### Visual Debug (Browser Visível)
```bash
# Simplesmente rode com HEADLESS=false
HEADLESS=false node read-chat.js "URL"
```

### Chrome DevTools Remote (Recommended)
Para debug remoto em servidor ou processos longos:

```javascript
// Adicione nos scripts:
const browser = await chromium.launch({
  headless: false,  // ou true
  args: [
    '--remote-debugging-port=9222',
    '--remote-debugging-address=0.0.0.0'
  ]
});
```

**Acesso:**
```bash
# Se remoto, crie SSH tunnel
ssh -L 9222:localhost:9222 user@servidor

# No seu Chrome local, vá para:
chrome://inspect

# Configure "Discover network targets" → localhost:9222
# Clique "inspect" na página que aparecer
```

**Resultado:** Veja DOM, console, network, cookies em tempo real! 🔥

### Playwright Trace Viewer (Timeline Interativa)
```javascript
// Adicione no início do script:
const context = await browser.newContext();
await context.tracing.start({ 
  screenshots: true, 
  snapshots: true 
});

// ... seu código ...

// No final:
await context.tracing.stop({ 
  path: `trace-${Date.now()}.zip` 
});
```

**Visualizar:**
```bash
npx playwright show-trace trace-*.zip
```

**Resultado:** Timeline com screenshots de cada ação, DOM snapshots, network requests! 📹

### Screenshots Automáticos
```javascript
// Capture momentos importantes:
await page.screenshot({ 
  path: `debug-${Date.now()}.png`,
  fullPage: true 
});
```

### Gravar Vídeo
```javascript
const context = await browser.newContext({
  recordVideo: {
    dir: './videos/',
    size: { width: 1280, height: 720 }
  }
});

// O vídeo é salvo automaticamente ao fechar o context
await context.close();
```

### Debug Flag (Sugestão de Implementação)
Adicione suporte para flag `--debug`:

```javascript
const DEBUG = process.argv.includes('--debug');

if (DEBUG) {
  browser = await chromium.launch({
    headless: false,
    slowMo: 500,  // Slow motion
    args: ['--remote-debugging-port=9222']
  });
  
  await context.tracing.start({ 
    screenshots: true, 
    snapshots: true 
  });
}

// No final
if (DEBUG) {
  await context.tracing.stop({ 
    path: `trace-${Date.now()}.zip` 
  });
  console.log('🔍 Run: npx playwright show-trace trace-*.zip');
}
```

**Uso:**
```bash
node read-chat.js URL --debug
```

## Arquitetura

```
poc-playwright/
├── package.json          # Dependências
├── cookies.json          # Seus cookies (não commitado)
├── read-chat.js          # Script para ler mensagens
├── write-chat.js         # Script para escrever mensagens
└── README.md             # Este arquivo
```

## Segurança

- ⚠️ **NUNCA commite cookies.json** para o Git
- ⚠️ **NUNCA compartilhe seus cookies** - eles dão acesso total à sua conta
- 🔒 Use esta POC apenas para fins de desenvolvimento e testes
- 🔒 Respeite os Termos de Serviço do LinkedIn

## Planned Features (Candidate Recruitment Workflow)

### Core Features

#### 1. Thread Management
- **List recruiting conversations** with auto-detected job details
- **Track process stages** (first_contact, interview, offer, etc.)
- **Monitor response status** (awaiting candidate/recruiter response)
- **Days since last contact** tracking

#### 2. Document Sharing
- **Send resume/CV** with one command
- **Share portfolio links** (GitHub, personal site)
- **Attach cover letters** and other documents
- **File type detection** and validation

#### 3. Availability Sharing
- **Share Calendly links** with formatted message
- **Send structured time slots** in readable format
- **Timezone handling** for international interviews
- **Calendar integration** helpers

#### 4. Smart Reminders
- **Follow-up reminders** (e.g., "follow up in 3 days")
- **Action tracking** (pending responses, scheduled interviews)
- **Automatic nudges** with polite templates
- **Overdue detection** for stalled processes

#### 5. Process Intelligence (LLM-powered)
- **Auto-extract job details** (title, salary, location, tech stack)
- **Timeline tracking** (days in process, decision dates)
- **Stage detection** (screening, technical, offer, etc.)
- **Sentiment analysis** (positive, neutral, concerning)
- **Red flag detection** (long delays, unclear communication)
- **Recruiter responsiveness** scoring

#### 6. Template Responses
```javascript
// Pre-built templates for common scenarios:
- accept_interview
- request_reschedule
- follow_up_gentle
- decline_offer_polite
- request_more_info
- thank_you_post_interview
- accept_offer
- negotiate_salary
```

#### 7. Multi-Process Dashboard
- **Active processes summary** (count, status breakdown)
- **Health indicators** (on_track, delayed, at_risk)
- **Priority scoring** based on stage and timeline
- **Next action recommendations**

#### 8. Interview Prep Assistant
- **Analyze thread** for interview hints
- **Extract mentioned topics** (system design, coding, etc.)
- **Company values** detection from messages
- **Suggested questions** to ask the interviewer

#### 9. Salary Negotiation Helper
- **Draft negotiation messages** with proper tone
- **Justification builder** (market rate, experience, offers)
- **Tone options** (collaborative, firm, grateful)
- **Counter-offer templates**

#### 10. Process Archive
- **Export completed processes** to Rails app
- **Outcome tracking** (accepted, rejected, withdrew, ghosted)
- **Rating and notes** for future reference
- **Create Deal/Recruiter records** automatically

### Agent Features (Automation)

#### Auto-Acknowledge
- **Automatic acknowledgment** of new recruiter messages
- **Configurable delay** (e.g., 2 hours before responding)
- **Customizable templates** for different scenarios

#### Stale Process Detector
- **Identify dormant threads** (no response in N days)
- **Suggest follow-up actions** with draft messages
- **Escalation alerts** for critical processes

#### Conflict Detector
- **Interview time conflicts** detection
- **Overlapping deadlines** warnings
- **Reschedule suggestions** with priorities

### Implementation Roadmap

**MVP (Weeks 1-2):**
1. ✅ Read/Write messages (completed)
2. 📎 Send documents/resume
3. 🔍 List recruiting threads
4. 📊 Basic thread analysis (stage, next steps)

**V2 (Weeks 3-4):**
5. 📅 Share availability (Calendly, time slots)
6. 📝 Template response system
7. ⏰ Reminder system
8. 📈 Multi-process dashboard

**V3 (Future):**
9. 🤖 Auto-acknowledge with smart delays
10. 💰 Salary negotiation assistant
11. 🎯 Interview prep analyzer
12. 📊 Full analytics dashboard

### API Endpoints (Planned)

```bash
# Thread Management
GET  /api/recruiting/threads
GET  /api/recruiting/analyze-thread/:id
POST /api/recruiting/archive

# Document Operations
POST /api/recruiting/send-resume
POST /api/recruiting/send-portfolio

# Communication
POST /api/recruiting/send-template
POST /api/recruiting/share-availability
POST /api/recruiting/negotiate

# Agent Features
GET  /api/recruiting/dashboard
GET  /api/agent/stale-processes
GET  /api/agent/conflicts
POST /api/agent/auto-acknowledge

# Interview Prep
POST /api/recruiting/interview-prep
POST /api/recruiting/set-reminder
GET  /api/recruiting/reminders
```

### Technology Stack (Future)

- **Scraping**: Playwright (Node.js) - current
- **API**: Rails REST API
- **Queue**: Sidekiq + Redis
- **Browser Pool**: Persistent Chromium instances
- **LLM**: Llama (via Rails LlamaSummarizer)
- **Storage**: PostgreSQL (Rails app)

## Licença

MIT - Use por sua conta e risco


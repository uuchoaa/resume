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

## Licença

MIT - Use por sua conta e risco


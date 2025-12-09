# Spotify Playlist Manager - TODO

## Database & Backend Setup
- [x] Estender schema do banco de dados com tabela para armazenar tokens do Spotify
- [x] Criar migrations para nova tabela de tokens

## Spotify OAuth Integration
- [x] Configurar variáveis de ambiente para Spotify OAuth (Client ID, Client Secret, Redirect URI)
- [x] Implementar fluxo de autorização OAuth 2.0 do Spotify
- [x] Criar endpoint para callback do Spotify OAuth
- [x] Implementar refresh de tokens expirados
- [x] Armazenar tokens de acesso e refresh tokens de forma segura

## tRPC Procedures
- [x] Criar procedure para listar playlists do usuário autenticado
- [x] Criar procedure para atualizar privacidade de uma playlist (público/privado)
- [x] Criar procedure para atualizar privacidade em lote de múltiplas playlists
- [x] Implementar tratamento de erros e validação de tokens

## Frontend Interface
- [x] Instalar e configurar HeroUI
- [x] Criar página de login com redirecionamento para Spotify
- [x] Criar página principal com listagem de playlists
- [x] Implementar componente de playlist card com imagem, nome e status
- [x] Implementar seleção múltipla com checkboxes
- [x] Implementar ações em lote (tornar público/privado)
- [x] Adicionar links diretos para abrir playlists no Spotify
- [x] Implementar feedback visual de loading durante operações
- [x] Implementar design elegante e responsivo com Tailwind CSS

## Testing & Validation
- [x] Testar fluxo completo de autenticação
- [x] Testar listagem de playlists
- [x] Testar edição em lote de privacidade
- [x] Validar responsividade em diferentes dispositivos
- [x] Testar tratamento de erros e edge cases

## Deployment & Documentation
- [x] Criar checkpoint final
- [x] Documentar instruções de configuração do Spotify OAuth


## Mock Mode for Testing
- [ ] Criar dados mock realistas com playlists fictícias
- [ ] Implementar toggle de modo mock no backend
- [ ] Criar procedures tRPC para retornar dados mock
- [ ] Implementar toggle de modo mock no frontend
- [ ] Testar todas as telas com dados mock
- [ ] Documentar como usar o modo mock

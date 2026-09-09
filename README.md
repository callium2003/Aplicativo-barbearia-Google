# BarbeariaSP

Base inicial da plataforma SaaS de agendamento e gestão para barbearias. A primeira entrega inclui uma aplicação Next.js com TypeScript estrito, tokens visuais, landing comercial responsiva e a fundação multiempresa no Supabase.

## Executar localmente

1. Copie `.env.example` para `.env.local` e preencha as variáveis quando o Supabase for integrado.
2. Instale as dependências: `npm install`.
3. Execute em desenvolvimento: `npm run dev`.
4. Abra [http://localhost:3000](http://localhost:3000).

## Ambiente Supabase local

1. Instale o [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) e o Docker.
2. Execute `supabase start` na raiz do projeto.
3. Copie `.env.example` para `.env.local` e preencha `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` com a chave publicada pelo CLI.
4. A migration da Fase B será aplicada pelo Supabase em `supabase/migrations/`.

As chaves `SUPABASE_SERVICE_ROLE_KEY`, `RESEND_API_KEY`, `ASAAS_API_KEY` e `NOTIFICATION_CRON_SECRET` pertencem exclusivamente a serviços confiáveis e nunca devem receber o prefixo `NEXT_PUBLIC_`.

## Verificações

- `npm run lint`
- `npm run typecheck`
- `npm run build`

## Próximas entregas

- migrations Supabase e isolamento multiempresa;
- autenticação e cadastro inicial da barbearia;
- serviços, horários, profissionais e página pública;
- fluxo transacional de agendamento.

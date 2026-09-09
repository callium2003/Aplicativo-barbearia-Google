# BarbeariaSP

Base inicial da plataforma SaaS de agendamento e gestão para barbearias. A primeira entrega inclui a fundação de uma aplicação Next.js com TypeScript estrito, tokens visuais e landing comercial responsiva.

## Executar localmente

1. Copie `.env.example` para `.env.local` e preencha as variáveis quando o Supabase for integrado.
2. Instale as dependências: `npm install`.
3. Execute em desenvolvimento: `npm run dev`.
4. Abra [http://localhost:3000](http://localhost:3000).

## Verificações

- `npm run lint`
- `npm run typecheck`
- `npm run build`

## Próximas entregas

- migrations Supabase e isolamento multiempresa;
- autenticação e cadastro inicial da barbearia;
- serviços, horários, profissionais e página pública;
- fluxo transacional de agendamento.

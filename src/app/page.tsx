const features = [
  [
    "Agenda online",
    "Seu cliente escolhe data, serviços, profissional e horário em poucos passos.",
  ],
  [
    "Equipe organizada",
    "Profissionais, disponibilidade e acessos separados com as permissões certas.",
  ],
  [
    "Gestão clara",
    "Acompanhe atendimentos, clientes, serviços e resultados sem planilhas espalhadas.",
  ],
];

const plans = [
  ["Mensal", "R$ 99,90", "1 mês"],
  ["Trimestral", "R$ 284,90", "3 meses"],
  ["Semestral", "R$ 539,90", "6 meses"],
  ["Anual", "R$ 999,00", "12 meses"],
];

export default function Home() {
  return (
    <main>
      <header className="site-header">
        <a className="brand" href="#inicio" aria-label="BarbeariaSP, início">
          Barbearia<span>SP</span>
        </a>
        <nav aria-label="Navegação principal">
          <a href="#recursos">Recursos</a>
          <a href="#planos">Planos</a>
          <a href="#seguranca">Segurança</a>
        </nav>
        <div className="header-actions">
          <a className="text-link" href="/entrar">
            Entrar
          </a>
          <a className="button compact" href="/cadastro-inicial">
            Começar teste
          </a>
        </div>
      </header>

      <section id="inicio" className="hero" aria-labelledby="hero-title">
        <div className="hero-content">
          <p className="eyebrow">GESTÃO PARA BARBEARIAS</p>
          <h1 id="hero-title">
            A agenda da sua barbearia, no ritmo do seu negócio.
          </h1>
          <p className="hero-copy">
            Organize horários, equipe e clientes em uma experiência simples para
            quem atende e para quem agenda.
          </p>
          <div className="hero-actions">
            <a className="button" href="/cadastro-inicial">
              Começar teste grátis
            </a>
            <a className="button secondary" href="#recursos">
              Conhecer a plataforma
            </a>
          </div>
          <p className="fine-print">
            30 dias para testar. Sem cartão de crédito.
          </p>
        </div>
        <div className="hero-visual" aria-hidden="true">
          <div className="barber-pole">
            <i />
            <i />
            <i />
            <i />
            <i />
          </div>
          <p>
            BARBEARIA
            <br />
            <strong>SP</strong>
          </p>
        </div>
      </section>

      <section
        id="recursos"
        className="section"
        aria-labelledby="features-title"
      >
        <p className="eyebrow">TUDO EM UM SÓ LUGAR</p>
        <h2 id="features-title">
          Mais tempo para atender. Menos tempo para organizar.
        </h2>
        <div className="feature-grid">
          {features.map(([title, description], index) => (
            <article className="card" key={title}>
              <span className="feature-number">0{index + 1}</span>
              <h3>{title}</h3>
              <p>{description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section steps" aria-labelledby="steps-title">
        <div>
          <p className="eyebrow">UMA JORNADA SIMPLES</p>
          <h2 id="steps-title">
            Do primeiro acesso ao agendamento confirmado.
          </h2>
        </div>
        <ol>
          <li>
            <strong>Configure sua barbearia.</strong>
            <span>Cadastre dados, horários, serviços e sua equipe.</span>
          </li>
          <li>
            <strong>Compartilhe sua página.</strong>
            <span>Tenha um link público para receber novos agendamentos.</span>
          </li>
          <li>
            <strong>Opere com tranquilidade.</strong>
            <span>Acompanhe a agenda e mantenha seus clientes por perto.</span>
          </li>
        </ol>
      </section>

      <section
        id="seguranca"
        className="section security"
        aria-labelledby="security-title"
      >
        <p className="eyebrow">SEUS DADOS, SEU CONTROLE</p>
        <h2 id="security-title">Cada barbearia opera em seu próprio espaço.</h2>
        <p>
          O BarbeariaSP é planejado para separar os dados de cada negócio e
          respeitar as permissões de cada pessoa da equipe.
        </p>
      </section>

      <section id="planos" className="section" aria-labelledby="plans-title">
        <p className="eyebrow">PLANOS</p>
        <h2 id="plans-title">Escolha o período que faz sentido para você.</h2>
        <div className="plan-grid">
          {plans.map(([name, price, duration]) => (
            <article className="plan" key={name}>
              <h3>{name}</h3>
              <p className="price">{price}</p>
              <p>{duration} de acesso · Até 5 profissionais ativos</p>
              <a className="button secondary" href="/cadastro-inicial">
                Começar teste
              </a>
            </article>
          ))}
        </div>
      </section>

      <section className="final-cta" aria-labelledby="cta-title">
        <p className="eyebrow">PRONTO PARA COMEÇAR?</p>
        <h2 id="cta-title">Sua próxima agenda começa aqui.</h2>
        <a className="button" href="/cadastro-inicial">
          Criar minha barbearia
        </a>
      </section>

      <footer>
        <a className="brand" href="#inicio">
          Barbearia<span>SP</span>
        </a>
        <p>Uma plataforma para a rotina da sua barbearia.</p>
        <div>
          <a href="/privacidade">Privacidade</a>
          <a href="/termos">Termos de uso</a>
        </div>
      </footer>
    </main>
  );
}

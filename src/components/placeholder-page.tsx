import Link from "next/link";

type PlaceholderPageProps = {
  eyebrow: string;
  title: string;
  description: string;
};

export function PlaceholderPage({
  eyebrow,
  title,
  description,
}: PlaceholderPageProps) {
  return (
    <main className="placeholder-page">
      <Link className="brand" href="/">
        Barbearia<span>SP</span>
      </Link>
      <section aria-labelledby="page-title">
        <p className="eyebrow">{eyebrow}</p>
        <h1 id="page-title">{title}</h1>
        <p>{description}</p>
        <Link className="button" href="/">
          Voltar para o início
        </Link>
      </section>
    </main>
  );
}

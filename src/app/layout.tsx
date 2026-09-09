import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "BarbeariaSP | Gestão simples para barbearias",
  description:
    "Agenda online, gestão de equipe e relacionamento com clientes para barbearias.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="pt-BR">
      <body>{children}</body>
    </html>
  );
}

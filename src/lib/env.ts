type PublicEnvironment = {
  appUrl: string;
  supabaseUrl: string;
  supabasePublishableKey: string;
};

function requiredPublicValue(name: string): string {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Configuração obrigatória ausente: ${name}.`);
  }

  return value;
}

export function getPublicEnvironment(): PublicEnvironment {
  const appUrl = requiredPublicValue("NEXT_PUBLIC_APP_URL");
  const supabaseUrl = requiredPublicValue("NEXT_PUBLIC_SUPABASE_URL");
  const supabasePublishableKey = requiredPublicValue(
    "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
  );

  return { appUrl, supabaseUrl, supabasePublishableKey };
}

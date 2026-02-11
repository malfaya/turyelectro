CREATE TABLE IF NOT EXISTS public.clientes (
  id BIGSERIAL PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  email VARCHAR(160) UNIQUE,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.clientes (nombre, email)
VALUES
  ('Cliente Demo', 'demo@turyelectro.com')
ON CONFLICT (email) DO NOTHING;

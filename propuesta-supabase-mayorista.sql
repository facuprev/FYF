-- PROPUESTA SIN EJECUTAR: revisar con FYF antes de pegar en Supabase.
-- Crea tablas separadas para el catálogo y la gestión mayorista.
-- No borra ni altera productos, ventas ni políticas existentes.
-- Los 80 productos se importan desactivados y sin foto: primero hay que vincular cada imagen.
-- No descuenta stock automáticamente; la disponibilidad queda como dato manual.

create table if not exists public.productos_mayoristas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  categoria text not null,
  precio_mayorista integer not null check (precio_mayorista >= 0),
  producto_id bigint references public.productos(id) on delete set null,
  imagen text default '',
  disponibilidad text not null default 'consultar'
    check (disponibilidad in ('disponible','consultar','por_encargo','sin_stock')),
  activo boolean not null default false,
  orden integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.clientes_mayoristas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  negocio text default '',
  whatsapp text not null unique,
  localidad text default '',
  created_at timestamptz not null default now()
);

create table if not exists public.pedidos_mayoristas (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.clientes_mayoristas(id),
  total integer not null check (total >= 0),
  estado text not null default 'nuevo'
    check (estado in ('nuevo','confirmado','preparando','enviado','entregado','cancelado')),
  pago_estado text not null default 'pendiente'
    check (pago_estado in ('pendiente','seña','pagado')),
  canal text not null default 'whatsapp',
  nota text default '',
  detalle jsonb not null default '[]'::jsonb check (jsonb_typeof(detalle) = 'array'),
  created_at timestamptz not null default now()
);

alter table public.productos_mayoristas enable row level security;
alter table public.clientes_mayoristas enable row level security;
alter table public.pedidos_mayoristas enable row level security;

grant select on public.productos_mayoristas to anon, authenticated;
grant insert, update on public.productos_mayoristas to authenticated;
grant select, insert, update on public.clientes_mayoristas to authenticated;
grant select, insert, update on public.pedidos_mayoristas to authenticated;

drop policy if exists "Public can read active wholesale products" on public.productos_mayoristas;
drop policy if exists "FYF admin manages wholesale products" on public.productos_mayoristas;
drop policy if exists "FYF admin manages wholesale clients" on public.clientes_mayoristas;
drop policy if exists "FYF admin manages wholesale orders" on public.pedidos_mayoristas;

create policy "Public can read active wholesale products"
  on public.productos_mayoristas for select to anon, authenticated
  using (activo = true);
create policy "FYF admin manages wholesale products"
  on public.productos_mayoristas for all to authenticated
  using ((auth.jwt() ->> 'email') = 'facprev@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'facprev@gmail.com');
create policy "FYF admin manages wholesale clients"
  on public.clientes_mayoristas for all to authenticated
  using ((auth.jwt() ->> 'email') = 'facprev@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'facprev@gmail.com');
create policy "FYF admin manages wholesale orders"
  on public.pedidos_mayoristas for all to authenticated
  using ((auth.jwt() ->> 'email') = 'facprev@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'facprev@gmail.com');

insert into public.productos_mayoristas (nombre, categoria, precio_mayorista, orden)
values
  ('Corona', 'Mates', 27000, 1),
  ('Torpedo roma uruguayo cincelado al lacre', 'Mates', 48600, 2),
  ('Matera cuadrada cuero premium', 'Materas y canastas', 36600, 3),
  ('Matera sol de mayo cuero avejentado premium 2 espacios', 'Materas y canastas', 34200, 4),
  ('Torpedo rey criollo cuero crudo', 'Mates', 49800, 5),
  ('Torpedo cincelada alpaca algarrobo', 'Mates', 18600, 6),
  ('Bombillas de acero inox', 'Bombillas', 3096, 7),
  ('Grabados bombillas', 'Bombillas', 1200, 8),
  ('Bombilla de acero chata acero inox', 'Bombillas', 2400, 9),
  ('Imperial fleje y virola de acero premium', 'Mates', 18600, 10),
  ('Imperial algarrobo alpaca', 'Mates', 15840, 11),
  ('Grabados mates', 'Accesorios', 4800, 12),
  ('Camionero criollo con base cuero crudo', 'Mates', 13800, 13),
  ('Torpedo virolon uruguayo cincelado', 'Mates', 34200, 14),
  ('Camionero uruguayo acero inox', 'Mates', 15600, 15),
  ('Imperial cincelado alpaca', 'Mates', 21000, 16),
  ('Imperial base bolitas fleje alpaca virola de acero', 'Mates', 31800, 17),
  ('Torpedo avejentado cincelado al lacre + base bolitas', 'Mates', 51000, 18),
  ('Imperial exclusivo base bolitas cuero repujado al cincelada', 'Mates', 48600, 19),
  ('Coquito con base cuero crudo', 'Mates', 15000, 20),
  ('Termo negro media manija', 'Termos', 18600, 21),
  ('Matera cuero crudo 2 espacios', 'Materas y canastas', 59400, 22),
  ('Bombilla pico de loro acero pico de bronce', 'Bombillas', 4620, 23),
  ('Mates ranchero', 'Mates', 23400, 24),
  ('Bombillon alpaca y pico de bronce cincelada', 'Bombillas', 18000, 25),
  ('Yerba BALDO 1kg', 'Yerbas', 9400, 26),
  ('Yerba ESMERALDA 1kg', 'Yerbas', 9600, 27),
  ('Yerba Canarias tradicional 1kg', 'Yerbas', 10600, 28),
  ('Yerba Canarias suave 1kg', 'Yerbas', 10900, 29),
  ('Yerba Canarias serena 1kg', 'Yerbas', 10900, 30),
  ('Yerba Canarias te rojo y centella 1kg', 'Yerbas', 11600, 31),
  ('Yerba Canarias te verde 1kg', 'Yerbas', 11600, 32),
  ('Yerba REI verde tradicional 1kg', 'Yerbas', 7500, 33),
  ('Yerba REI verde premium 1kg', 'Yerbas', 9500, 34),
  ('Yerba SARA tradicional 1kg', 'Yerbas', 10100, 35),
  ('Yerba SARA suave 1kg', 'Yerbas', 10100, 36),
  ('Yerba SARA de coco 1kg', 'Yerbas', 7700, 37),
  ('Imperial Clasico Acero', 'Mates', 17400, 38),
  ('Imperial rey', 'Mates', 32400, 39),
  ('Imperial cuero crudo', 'Mates', 33600, 40),
  ('Imperial algarrobo cincelado', 'Mates', 17400, 41),
  ('Imperial algarrobo virola combinada', 'Mates', 13800, 42),
  ('Imperial avejentado', 'Mates', 32400, 43),
  ('Imperial premium', 'Mates', 33600, 44),
  ('Imperial Clasico', 'Mates', 20280, 45),
  ('Imperial full alpaca', 'Mates', 22200, 46),
  ('Imperial animal print', 'Mates', 28800, 47),
  ('Imperial animal print base con bolitas', 'Mates', 33600, 48),
  ('Imperial base canasta', 'Materas y canastas', 28200, 49),
  ('Camionero clasico', 'Mates', 14640, 50),
  ('Camionero algarrobo', 'Mates', 9000, 51),
  ('Camionero laqueado', 'Mates', 9840, 52),
  ('Camionero base canasta', 'Materas y canastas', 25200, 53),
  ('Camionero premium', 'Mates', 31200, 54),
  ('Torpedo clasico', 'Mates', 21000, 55),
  ('Torpedo clasico repujado', 'Mates', 25800, 56),
  ('Torpedo cincelado al lacre', 'Mates', 28800, 57),
  ('Torpedo joyero avejentado', 'Mates', 33000, 58),
  ('Torpedo avejentado clasico', 'Mates', 40800, 59),
  ('Torpedo avejentado sol de mayo', 'Mates', 46200, 60),
  ('Torpedo aventado corona', 'Mates', 46200, 61),
  ('Torpedo animal print', 'Mates', 28800, 62),
  ('Torpedo animal print base bolitas', 'Mates', 33600, 63),
  ('Torpedo Premium', 'Mates', 33600, 64),
  ('Torpedo exclusivo', 'Mates', 78000, 65),
  ('Torpedo cuero crudo lacre', 'Mates', 37800, 66),
  ('Torpedo base canasta premium', 'Materas y canastas', 31800, 67),
  ('Canasta estancia', 'Materas y canastas', 25200, 68),
  ('Canasta cordillera', 'Materas y canastas', 32400, 69),
  ('Canasta sol de mayo', 'Materas y canastas', 34800, 70),
  ('Canasta cuero crudo', 'Materas y canastas', 54000, 71),
  ('Canasta tribal', 'Materas y canastas', 54000, 72),
  ('Termo contigo 1L', 'Termos', 72000, 73),
  ('Termo THERMOS 1L', 'Termos', 84000, 74),
  ('Termo media manija blanco', 'Termos', 18000, 75),
  ('Termo media manija negro', 'Termos', 18000, 76),
  ('Bombilla de alpaca pico de pato', 'Bombillas', 16200, 77),
  ('Caja de presentacion', 'Accesorios', 7188, 78),
  ('Lata baldo 500 GR', 'Accesorios', 18450, 79),
  ('Canasta cuerina grande con división', 'Materas y canastas', 8148, 80)

on conflict (nombre) do nothing;

-- La lista se importa desactivada hasta vincular la foto correcta y revisar precios.
-- Desde el panel se puede actualizar el precio, elegir la foto y marcar la publicación.
-- No se modifica el stock minorista ni se descuenta stock al guardar un pedido.


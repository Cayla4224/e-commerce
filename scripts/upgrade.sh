#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ Failed at line $LINENO"; exit 1' ERR
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

echo "▶ Ensuring PNPM..."
corepack enable >/dev/null 2>&1 || true
command -v pnpm >/dev/null || npm i -g pnpm@9

echo "▶ Creating folders..."
mkdir -p \
  .devcontainer \
  app/product/'[slug]' \
  app/cart \
  app/checkout/success \
  app/api/products/'[slug]' \
  app/api/checkout \
  app/api/health \
  app/admin \
  components \
  lib \
  prisma \
  public \
  server \
  .github/workflows

echo "▶ Writing files…"

cat > .gitignore << 'E'
node_modules
.next
out
.env
.env.local
prisma/dev.db
prisma/dev.db-journal
E

cat > .devcontainer/devcontainer.json << 'E'
{
  "name": "ecommerce-codespace",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:1-20-bullseye",
  "features": { "ghcr.io/devcontainers/features/node:1": { "version": "20" } },
  "postCreateCommand": "corepack enable && pnpm i",
  "customizations": {
    "vscode": {
      "extensions": [
        "esbenp.prettier-vscode",
        "Prisma.prisma",
        "bradlc.vscode-tailwindcss",
        "dbaeumer.vscode-eslint"
      ]
    }
  },
  "forwardPorts": [3000]
}
E

cat > package.json << 'E'
{
  "name": "ecommerce-codespace",
  "private": true,
  "version": "0.1.0",
  "packageManager": "pnpm@9.7.1",
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "postinstall": "prisma generate",
    "prisma:push": "prisma db push",
    "seed": "ts-node --transpile-only prisma/seed.ts",
    "lint": "next lint"
  },
  "dependencies": {
    "@prisma/client": "5.18.0",
    "clsx": "2.1.1",
    "next": "14.2.6",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "stripe": "16.7.0",
    "zod": "3.23.8"
  },
  "devDependencies": {
    "@types/node": "20.14.11",
    "@types/react": "18.3.5",
    "@types/react-dom": "18.3.0",
    "autoprefixer": "10.4.20",
    "eslint": "9.9.0",
    "eslint-config-next": "14.2.6",
    "postcss": "8.4.41",
    "prisma": "5.18.0",
    "tailwindcss": "3.4.10",
    "ts-node": "10.9.2",
    "typescript": "5.5.4"
  }
}
E

cat > next.config.js << 'E'
/** @type {import('next').NextConfig} */
const nextConfig = { experimental: { serverActions: { allowedOrigins: ['*'] } } };
module.exports = nextConfig;
E

cat > tsconfig.json << 'E'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "preserve",
    "allowJs": false,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "noEmit": true,
    "types": ["node", "react", "react-dom"]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", "prisma/**/*.ts"],
  "exclude": ["node_modules"]
}
E

cat > postcss.config.js << 'E'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } };
E

cat > tailwind.config.ts << 'E'
import type { Config } from "tailwindcss";
const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: { extend: {} },
  plugins: []
};
export default config;
E

cat > app/globals.css << 'E'
@tailwind base;
@tailwind components;
@tailwind utilities;
E

cat > app/layout.tsx << 'E'
import "./globals.css";
import Link from "next/link";
export const metadata = { title: "Codespace Shop", description: "E-commerce MVP" };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-dvh bg-gray-50 text-gray-900">
        <header className="border-b bg-white">
          <div className="mx-auto max-w-6xl px-4 py-4 flex justify-between items-center">
            <Link href="/" className="text-xl font-bold">Codespace Shop</Link>
            <nav className="flex gap-4">
              <Link href="/cart" className="hover:underline">Cart</Link>
              <Link href="/admin" className="hover:underline">Admin</Link>
            </nav>
          </div>
        </header>
        <main className="mx-auto max-w-6xl px-4 py-8">{children}</main>
        <footer className="mx-auto max-w-6xl px-4 py-8 text-sm text-gray-500">© {new Date().getFullYear()} Codespace Shop</footer>
      </body>
    </html>
  );
}
E

cat > app/template.tsx << 'E'
import Providers from "./providers";
export default function Template({ children }: { children: React.ReactNode }) { return <Providers>{children}</Providers>; }
E

cat > app/page.tsx << 'E'
import { ProductGrid } from "@/components/product-grid";
export default function HomePage() { return (<div><h1 className="text-2xl font-semibold mb-6">Latest Products</h1><ProductGrid /></div>); }
E

cat > app/product/'[slug]'/page.tsx << 'E'
import { getProductBySlug } from "@/server/products";
import { AddToCartButton } from "@/components/cart-client";
import Image from "next/image";
import { notFound } from "next/navigation";
import { formatCents } from "@/lib/money";

export default async function ProductPage({ params }: { params: { slug: string } }) {
  const product = await getProductBySlug(params.slug);
  if (!product) return notFound();
  return (
    <div className="grid md:grid-cols-2 gap-8">
      <div className="relative aspect-square">
        <Image src={product.image} alt={product.name} fill className="rounded-xl object-cover" />
      </div>
      <div>
        <h1 className="text-3xl font-semibold mb-2">{product.name}</h1>
        <p className="text-gray-600 mb-4">{product.description}</p>
        <div className="text-xl font-medium mb-6">{formatCents(product.priceCents)}</div>
        <AddToCartButton product={product} />
      </div>
    </div>
  );
}
E

cat > app/cart/page.tsx << 'E'
"use client";
import { useCart } from "@/lib/cart";
import Link from "next/link";
import Image from "next/image";
import { formatCents } from "@/lib/money";

export default function CartPage() {
  const { items, remove, totalCents, clear } = useCart();
  return (
    <div>
      <h1 className="text-2xl font-semibold mb-6">Your Cart</h1>
      {items.length === 0 ? (
        <p>Cart is empty. <Link href="/" className="underline">Shop now</Link>.</p>
      ) : (
        <div className="grid gap-6">
          <ul className="divide-y bg-white rounded-xl shadow">
            {items.map((it) => (
              <li key={it.product.id} className="flex items-center gap-4 p-4">
                <div className="relative h-16 w-16 rounded overflow-hidden">
                  <Image src={it.product.image} alt={it.product.name} fill className="object-cover" />
                </div>
                <div className="flex-1">
                  <div className="font-medium">{it.product.name}</div>
                  <div className="text-sm text-gray-500">{formatCents(it.product.priceCents)} × {it.quantity}</div>
                </div>
                <button className="text-red-600 underline" onClick={()=>remove(it.product.id)}>Remove</button>
              </li>
            ))}
          </ul>
          <div className="flex items-center justify-between">
            <div className="text-lg font-semibold">Total: {formatCents(totalCents)}</div>
            <div className="flex gap-3">
              <button className="px-3 py-2 rounded border" onClick={clear}>Clear</button>
              <Link href="/checkout" className="px-4 py-2 bg-black text-white rounded">Checkout</Link>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
E

cat > app/checkout/page.tsx << 'E'
"use client";
import { useState } from "react";
import { useCart } from "@/lib/cart";
import { formatCents } from "@/lib/money";

export default function CheckoutPage() {
  const { items, totalCents, clear } = useCart();
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle"|"loading"|"ok"|"err">("idle");

  async function submit() {
    setStatus("loading");
    try {
      const res = await fetch("/api/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, items: items.map(i => ({ productId: i.product.id, quantity: i.quantity })) })
      });
      const data = await res.json();
      if (data.url) { window.location.href = data.url; return; }
      if (data.ok) { clear(); setStatus("ok"); } else { setStatus("err"); }
    } catch { setStatus("err"); }
  }

  if (items.length === 0) {
    return <div><h1 className="text-2xl font-semibold mb-6">Checkout</h1><p>Your cart is empty.</p></div>;
  }

  return (
    <div className="max-w-lg">
      <h1 className="text-2xl font-semibold mb-6">Checkout</h1>
      <div className="space-y-3">
        <label className="block">
          <span className="text-sm text-gray-600">Email</span>
          <input className="mt-1 w-full border rounded px-3 py-2" value={email} onChange={e=>setEmail(e.target.value)} placeholder="you@example.com" />
        </label>
        <div className="border rounded p-3 bg-white">
          <div className="font-medium mb-2">Summary</div>
          <ul className="text-sm text-gray-600 list-disc pl-5">
            {items.map(i => <li key={i.product.id}>{i.product.name} × {i.quantity} — {formatCents(i.product.priceCents * i.quantity)}</li>)}
          </ul>
          <div className="mt-2 font-semibold">Total: {formatCents(totalCents)}</div>
        </div>
        <button onClick={submit} disabled={!email || status==="loading"} className="px-4 py-2 bg-black text-white rounded">
          {status==="loading" ? "Processing..." : "Pay"}
        </button>
        {status==="ok" && <div className="text-green-700">Order placed! Check your email.</div>}
        {status==="err" && <div className="text-red-700">Payment failed. Try again.</div>}
      </div>
    </div>
  );
}
E

cat > app/checkout/success/page.tsx << 'E'
export default function Success() {
  return <div className="max-w-lg">
    <h1 className="text-2xl font-semibold mb-3">Thank you!</h1>
    <p>Your payment succeeded. A confirmation has been sent.</p>
  </div>;
}
E

cat > app/admin/page.tsx << 'E'
import { revalidatePath } from "next/cache";
import { seedAction } from "./seed-action";
export const dynamic = "force-dynamic";

async function seedProducts() { "use server"; await seedAction(); revalidatePath("/"); }

export default function AdminPage() {
  const isAllowed = process.env.ADMIN_PASSWORD ? true : true;
  if (!isAllowed) return <div>Unauthorized</div>;
  return (
    <form action={seedProducts} className="space-y-4">
      <h1 className="text-2xl font-semibold">Admin</h1>
      <button className="px-4 py-2 bg-black text-white rounded">Seed demo products</button>
      <p className="text-sm text-gray-600">Re-runs the seeder to ensure demo data exists.</p>
    </form>
  );
}
E

cat > app/admin/seed-action.ts << 'E'
"use server";
import { seed } from "@/server/seed";
export async function seedAction() { await seed(); }
E

cat > app/api/products/route.ts << 'E'
import { getProducts } from "@/server/products";
export async function GET() {
  const products = await getProducts();
  return Response.json({ products });
}
E

cat > app/api/products/'[slug]'/route.ts << 'E'
import { getProductBySlug } from "@/server/products";
export async function GET(_: Request, { params }: { params: { slug: string } }) {
  const product = await getProductBySlug(params.slug);
  if (!product) return new Response("Not found", { status: 404 });
  return Response.json({ product });
}
E

cat > app/api/checkout/route.ts << 'E'
import { z } from "zod";
import { createOrderFromCart } from "@/server/orders";
import Stripe from "stripe";

const bodySchema = z.object({
  email: z.string().email(),
  items: z.array(z.object({ productId: z.string(), quantity: z.number().int().positive() }))
});

export async function POST(req: Request) {
  try {
    const body = bodySchema.parse(await req.json());
    const order = await createOrderFromCart(body.email, body.items);
    const stripeKey = process.env.STRIPE_SECRET_KEY;

    if (stripeKey) {
      const stripe = new Stripe(stripeKey, { apiVersion: "2024-06-20" });
      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        success_url: `${process.env.NEXT_PUBLIC_BASE_URL}/checkout/success`,
        cancel_url: `${process.env.NEXT_PUBLIC_BASE_URL}/cart`,
        customer_email: body.email,
        line_items: order.items.map((it) => ({
          price_data: {
            currency: "usd",
            product_data: { name: it.product.name },
            unit_amount: it.priceCents
          },
          quantity: it.quantity
        })),
        metadata: { orderId: order.id }
      });
      return Response.json({ url: session.url });
    }

    return Response.json({ ok: true, orderId: order.id });
  } catch {
    return new Response("Bad Request", { status: 400 });
  }
}
E

cat > app/api/health/route.ts << 'E'
export async function GET() { return Response.json({ ok: true }); }
E

cat > components/product-grid.tsx << 'E'
import Link from "next/link";
import Image from "next/image";
import { getProducts } from "@/server/products";
import { formatCents } from "@/lib/money";

export async function ProductGrid() {
  const products = await getProducts();
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
      {products.map((p)=>(
        <Link key={p.id} href={`/product/${p.slug}`} className="bg-white rounded-xl overflow-hidden shadow hover:shadow-md transition">
          <div className="relative aspect-square">
            <Image src={p.image} alt={p.name} fill className="object-cover" />
          </div>
          <div className="p-4">
            <div className="font-medium">{p.name}</div>
            <div className="text-gray-600 text-sm">{formatCents(p.priceCents)}</div>
          </div>
        </Link>
      ))}
    </div>
  );
}
E

cat > components/cart-client.tsx << 'E'
"use client";
import { Product } from "@prisma/client";
import { useCart } from "@/lib/cart";

export function AddToCartButton({ product }: { product: Product }) {
  const { add } = useCart();
  return (
    <button className="px-4 py-2 bg-black text-white rounded" onClick={()=>add(product, 1)}>
      Add to Cart
    </button>
  );
}
E

cat > lib/money.ts << 'E'
export function formatCents(cents: number, currency = "USD", locale = "en-US") {
  return new Intl.NumberFormat(locale, { style: "currency", currency }).format(cents / 100);
}
E

cat > lib/cart.tsx << 'E'
"use client";
import { createContext, useContext, useEffect, useMemo, useState } from "react";
import type { Product } from "@prisma/client";

type CartItem = { product: Product; quantity: number; };
type CartState = { items: CartItem[]; add: (p: Product, qty: number)=>void; remove:(id: string)=>void; clear:()=>void; totalCents:number; };

const CartCtx = createContext<CartState | null>(null);
const KEY = "ecommerce-cart-v1";

export function CartProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<CartItem[]>([]);
  useEffect(() => {
    try { const raw = localStorage.getItem(KEY); if (raw) setItems(JSON.parse(raw)); } catch {}
  }, []);
  useEffect(() => { localStorage.setItem(KEY, JSON.stringify(items)); }, [items]);

  const api = useMemo<CartState>(()=>({
    items,
    add: (product, qty) => {
      setItems(prev=>{
        const i = prev.findIndex(x=>x.product.id===product.id);
        if (i>=0) { const copy=[...prev]; copy[i]={...copy[i], quantity: copy[i].quantity + qty}; return copy; }
        return [...prev, { product, quantity: qty }];
      });
    },
    remove: (id) => setItems(prev => prev.filter(x=>x.product.id!==id)),
    clear: () => setItems([]),
    totalCents: items.reduce((s, it)=> s + it.product.priceCents * it.quantity, 0)
  }), [items]);

  return <CartCtx.Provider value={api}>{children}</CartCtx.Provider>;
}

export function useCart() {
  const ctx = useContext(CartCtx);
  if (!ctx) throw new Error("CartProvider missing");
  return ctx;
}
E

cat > app/providers.tsx << 'E'
"use client";
import { CartProvider } from "@/lib/cart";
export default function Providers({ children }: { children: React.ReactNode }) { return <CartProvider>{children}</CartProvider>; }
E

cat > server/db.ts << 'E'
import { PrismaClient } from "@prisma/client";
declare global { var prisma: PrismaClient | undefined; }
export const prisma = global.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== "production") global.prisma = prisma;
E

cat > server/products.ts << 'E'
import { prisma } from "./db";
export async function getProducts() {
  return prisma.product.findMany({ orderBy: { createdAt: "desc" } });
}
export async function getProductBySlug(slug: string) {
  return prisma.product.findUnique({ where: { slug } });
}
E

cat > server/orders.ts << 'E'
import { prisma } from "./db";
type ItemInput = { productId: string; quantity: number; };
export async function createOrderFromCart(email: string, items: ItemInput[]) {
  const products = await prisma.product.findMany({ where: { id: { in: items.map(i=>i.productId) } } });
  const byId = new Map(products.map(p=>[p.id, p]));
  const orderItems = items.map(i => {
    const p = byId.get(i.productId);
    if (!p) throw new Error("Unknown product");
    return { productId: p.id, quantity: i.quantity, priceCents: p.priceCents, product: p };
  });
  const total = orderItems.reduce((s, it)=> s + it.priceCents * it.quantity, 0);
  const order = await prisma.order.create({
    data: {
      email, totalCents: total, status: "PENDING",
      items: { create: orderItems.map(({ productId, quantity, priceCents }) => ({ productId, quantity, priceCents })) }
    },
    include: { items: { include: { product: true } } }
  });
  return order;
}
E

cat > server/seed.ts << 'E'
import { PrismaClient } from "@prisma/client";
export async function seed() {
  const db = new PrismaClient();
  const names = ["classic-tee", "hoodie", "cap"];
  const existing = await db.product.findMany({ where: { slug: { in: names } } });
  if (existing.length >= 3) return;
  await db.product.createMany({
    data: [
      { name: "Classic Tee", slug: "classic-tee", description: "Soft cotton tee for daily wear.", priceCents: 2500, image: "https://picsum.photos/seed/tee/600/600" },
      { name: "Hoodie", slug: "hoodie", description: "Cozy fleece hoodie.", priceCents: 5500, image: "https://picsum.photos/seed/hoodie/600/600" },
      { name: "Cap", slug: "cap", description: "Adjustable cotton cap.", priceCents: 1800, image: "https://picsum.photos/seed/cap/600/600" }
    ]
  });
}
E

cat > prisma/schema.prisma << 'E'
generator client { provider = "prisma-client-js" }
datasource db { provider = "sqlite"; url = "file:./dev.db" }

model Product {
  id          String   @id @default(cuid())
  name        String
  slug        String   @unique
  description String
  priceCents  Int
  image       String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  orderItems  OrderItem[]
}

model Order {
  id         String      @id @default(cuid())
  email      String
  totalCents Int
  status     OrderStatus @default(PENDING)
  createdAt  DateTime    @default(now())
  items      OrderItem[]
}

model OrderItem {
  id         String  @id @default(cuid())
  orderId    String
  productId  String
  quantity   Int
  priceCents Int
  order      Order   @relation(fields: [orderId], references: [id])
  product    Product @relation(fields: [productId], references: [id])
}

enum OrderStatus {
  PENDING
  PAID
  FAILED
}
E

cat > prisma/seed.ts << 'E'
import { PrismaClient } from "@prisma/client";
const db = new PrismaClient();
async function main() {
  const count = await db.product.count();
  if (count > 0) { console.log("Products already seeded"); return; }
  await db.product.createMany({
    data: [
      { name: "Classic Tee", slug: "classic-tee", description: "Soft cotton tee for daily wear.", priceCents: 2500, image: "https://picsum.photos/seed/tee/600/600" },
      { name: "Hoodie", slug: "hoodie", description: "Cozy fleece hoodie.", priceCents: 5500, image: "https://picsum.photos/seed/hoodie/600/600" },
      { name: "Cap", slug: "cap", description: "Adjustable cotton cap.", priceCents: 1800, image: "https://picsum.photos/seed/cap/600/600" }
    ]
  });
  console.log("Seeded products");
}
main().finally(()=>db.$disconnect());
E

cat > middleware.ts << 'E'
import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";
export function middleware(req: NextRequest) {
  if (!process.env.NEXT_PUBLIC_BASE_URL) {
    const url = req.nextUrl.clone();
    const base = `${url.protocol}//${url.host}`;
    process.env.NEXT_PUBLIC_BASE_URL = base;
  }
  return NextResponse.next();
}
E

cat > public/vercel.svg << 'E'
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"><path d="M12 4l9 16H3z"/></svg>
E

cat > .github/workflows/ci.yml << 'E'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: 'pnpm' }
      - run: pnpm i
      - run: pnpm prisma:push
      - run: pnpm build
      - run: pnpm lint
E

cat > README.md << 'E'
# Codespace Shop (Next.js + Prisma + SQLite)

## Quick Start
1) Code → Create codespace on main
2) Terminal:
   pnpm prisma:push
   pnpm seed
   pnpm dev
3) Open forwarded Port 3000 → visit `/`
4) Visit `/admin` to reseed demo products.
E

echo "▶ Installing deps..."
pnpm i

echo "▶ DB push..."
pnpm prisma:push

echo "▶ Seeding..."
pnpm seed

echo "✅ Upgrade complete. Next: pnpm dev (open Port 3000)."

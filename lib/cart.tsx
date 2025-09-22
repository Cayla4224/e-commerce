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

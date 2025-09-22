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

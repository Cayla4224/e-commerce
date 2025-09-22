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

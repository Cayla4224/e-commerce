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

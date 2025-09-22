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

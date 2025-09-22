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

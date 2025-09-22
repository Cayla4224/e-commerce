import { getProductBySlug } from "@/server/products";
export async function GET(_: Request, { params }: { params: { slug: string } }) {
  const product = await getProductBySlug(params.slug);
  if (!product) return new Response("Not found", { status: 404 });
  return Response.json({ product });
}

import { getProducts } from "@/server/products";
export async function GET() {
  const products = await getProducts();
  return Response.json({ products });
}

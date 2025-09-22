import { prisma } from "./db";
export async function getProducts() {
  return prisma.product.findMany({ orderBy: { createdAt: "desc" } });
}
export async function getProductBySlug(slug: string) {
  return prisma.product.findUnique({ where: { slug } });
}

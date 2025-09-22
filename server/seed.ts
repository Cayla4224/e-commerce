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

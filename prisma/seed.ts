import { PrismaClient } from "@prisma/client";
const db = new PrismaClient();
async function main() {
  const count = await db.product.count();
  if (count > 0) { console.log("Products already seeded"); return; }
  await db.product.createMany({
    data: [
      { name: "Classic Tee", slug: "classic-tee", description: "Soft cotton tee for daily wear.", priceCents: 2500, image: "https://picsum.photos/seed/tee/600/600" },
      { name: "Hoodie", slug: "hoodie", description: "Cozy fleece hoodie.", priceCents: 5500, image: "https://picsum.photos/seed/hoodie/600/600" },
      { name: "Cap", slug: "cap", description: "Adjustable cotton cap.", priceCents: 1800, image: "https://picsum.photos/seed/cap/600/600" }
    ]
  });
  console.log("Seeded products");
}
main().finally(()=>db.$disconnect());

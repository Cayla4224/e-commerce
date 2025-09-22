import { prisma } from "./db";
type ItemInput = { productId: string; quantity: number; };
export async function createOrderFromCart(email: string, items: ItemInput[]) {
  const products = await prisma.product.findMany({ where: { id: { in: items.map(i=>i.productId) } } });
  const byId = new Map(products.map(p=>[p.id, p]));
  const orderItems = items.map(i => {
    const p = byId.get(i.productId);
    if (!p) throw new Error("Unknown product");
    return { productId: p.id, quantity: i.quantity, priceCents: p.priceCents, product: p };
  });
  const total = orderItems.reduce((s, it)=> s + it.priceCents * it.quantity, 0);
  const order = await prisma.order.create({
    data: {
      email, totalCents: total, status: "PENDING",
      items: { create: orderItems.map(({ productId, quantity, priceCents }) => ({ productId, quantity, priceCents })) }
    },
    include: { items: { include: { product: true } } }
  });
  return order;
}

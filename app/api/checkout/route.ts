import { z } from "zod";
import { createOrderFromCart } from "@/server/orders";
import Stripe from "stripe";

const bodySchema = z.object({
  email: z.string().email(),
  items: z.array(z.object({ productId: z.string(), quantity: z.number().int().positive() }))
});

export async function POST(req: Request) {
  try {
    const body = bodySchema.parse(await req.json());
    const order = await createOrderFromCart(body.email, body.items);
    const stripeKey = process.env.STRIPE_SECRET_KEY;

    if (stripeKey) {
      const stripe = new Stripe(stripeKey, { apiVersion: "2024-06-20" });
      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        success_url: `${process.env.NEXT_PUBLIC_BASE_URL}/checkout/success`,
        cancel_url: `${process.env.NEXT_PUBLIC_BASE_URL}/cart`,
        customer_email: body.email,
        line_items: order.items.map((it) => ({
          price_data: {
            currency: "usd",
            product_data: { name: it.product.name },
            unit_amount: it.priceCents
          },
          quantity: it.quantity
        })),
        metadata: { orderId: order.id }
      });
      return Response.json({ url: session.url });
    }

    return Response.json({ ok: true, orderId: order.id });
  } catch {
    return new Response("Bad Request", { status: 400 });
  }
}

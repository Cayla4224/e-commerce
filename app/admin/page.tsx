import { revalidatePath } from "next/cache";
import { seedAction } from "./seed-action";
export const dynamic = "force-dynamic";

async function seedProducts() { "use server"; await seedAction(); revalidatePath("/"); }

export default function AdminPage() {
  const isAllowed = process.env.ADMIN_PASSWORD ? true : true;
  if (!isAllowed) return <div>Unauthorized</div>;
  return (
    <form action={seedProducts} className="space-y-4">
      <h1 className="text-2xl font-semibold">Admin</h1>
      <button className="px-4 py-2 bg-black text-white rounded">Seed demo products</button>
      <p className="text-sm text-gray-600">Re-runs the seeder to ensure demo data exists.</p>
    </form>
  );
}

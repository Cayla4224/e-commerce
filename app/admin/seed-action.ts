"use server";
import { seed } from "@/server/seed";
export async function seedAction() { await seed(); }

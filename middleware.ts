import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";
export function middleware(req: NextRequest) {
  if (!process.env.NEXT_PUBLIC_BASE_URL) {
    const url = req.nextUrl.clone();
    const base = `${url.protocol}//${url.host}`;
    process.env.NEXT_PUBLIC_BASE_URL = base;
  }
  return NextResponse.next();
}

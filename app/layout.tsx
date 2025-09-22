import "./globals.css";
import Link from "next/link";
export const metadata = { title: "Codespace Shop", description: "E-commerce MVP" };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-dvh bg-gray-50 text-gray-900">
        <header className="border-b bg-white">
          <div className="mx-auto max-w-6xl px-4 py-4 flex justify-between items-center">
            <Link href="/" className="text-xl font-bold">Codespace Shop</Link>
            <nav className="flex gap-4">
              <Link href="/cart" className="hover:underline">Cart</Link>
              <Link href="/admin" className="hover:underline">Admin</Link>
            </nav>
          </div>
        </header>
        <main className="mx-auto max-w-6xl px-4 py-8">{children}</main>
        <footer className="mx-auto max-w-6xl px-4 py-8 text-sm text-gray-500">© {new Date().getFullYear()} Codespace Shop</footer>
      </body>
    </html>
  );
}

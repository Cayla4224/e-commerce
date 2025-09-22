/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    // simplest allow-list for Next 14
    domains: ["picsum.photos"]
    // Or use remotePatterns if you need more control:
    // remotePatterns: [{ protocol: "https", hostname: "picsum.photos" }]
  },
  experimental: { serverActions: { allowedOrigins: ["*"] } }
};
module.exports = nextConfig;

// file: next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "picsum.photos",
        port: "",
        pathname: "/**"
      }
    ]
  },
  experimental: { serverActions: { allowedOrigins: ["*"] } }
};

module.exports = nextConfig;


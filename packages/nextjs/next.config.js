/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  api: {
    bodyParser: false,
  },
  typescript: {
    ignoreBuildErrors: true
  }
}

module.exports = nextConfig

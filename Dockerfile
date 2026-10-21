# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy package and config files
COPY package.json pnpm-lock.yaml .npmrc* pnpm-workspace.yaml* ./

# Install dependencies
RUN pnpm install

# Copy source
COPY . .

# Build Astro site
RUN pnpm run build

# Production stage
FROM nginx:alpine

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build output
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]

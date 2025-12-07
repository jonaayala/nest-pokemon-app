# Install dependencies only when needed
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Build the app
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build

# Production image
FROM node:20-alpine AS runner
WORKDIR /usr/src/app

COPY package.json yarn.lock ./
RUN yarn install --production=true

COPY --from=builder /app/dist ./dist

CMD ["node", "dist/main"]
# Setting up the base image
FROM node:23-slim AS base

# Setting up the development environment
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# STAGE 1: BUILDER
FROM base AS builder

# Setting up the working directory
WORKDIR /home/build

# Copying the setup files and dependency lists
COPY package.json pnpm-lock.yaml tsconfig.json ./

# Install All Dependencies
RUN pnpm install --frozen-lockfile

# Copying the source code
COPY app.config.ts ./
COPY app/ app/

# Building the application
RUN pnpm build

# STAGE 2: RUNNER
FROM base AS runner

# Setting up the working directory
WORKDIR /home/ts-blog

# Copying the built files from the builder stage
COPY --from=builder /home/build/.output .output/
COPY --from=builder /home/build/.vinxi .vinxi/

# Copying the setup files and dependency lists
COPY package.json pnpm-lock.yaml ./

# Install All Dependencies
RUN pnpm install --prod --frozen-lockfile

# Exposing the port (This is the port number we expose from the container)
EXPOSE 3000

# Starting the application
CMD ["pnpm", "start"]

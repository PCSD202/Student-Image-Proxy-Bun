FROM oven/bun:alpine AS base
WORKDIR /usr/app

# install dependencies into temp directory
# this will cache them and speed up future builds
FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json /temp/dev/
RUN cd /temp/dev && bun install --frozen-lockfile

# install with --production (exclude devDependencies)
RUN mkdir -p /temp/prod
COPY package.json bun.lockb /temp/prod/
RUN cd /temp/prod && bun install --frozen-lockfile --production

# copy node_modules from temp directory
# then copy all (non-ignored) project files into the image
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

# [optional] tests & build
ENV NODE_ENV=production
RUN bun build /usr/app/index.ts --compile --minify --sourcemap --bytecode --outfile dist/app

# copy production dependencies and source code into final image
FROM base AS release

COPY --from=prerelease /usr/app/dist/app ./dist/
COPY --from=prerelease /usr/app/package.json .

ENV API_KEY API_KEY

VOLUME [ "/public" ]

# run the app
EXPOSE 3000/tcp
ENTRYPOINT [  "./dist/app" ]
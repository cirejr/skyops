
ARG NGINX_VERSION=alpine3.22

FROM ghcr.io/pnpm/pnpm:12 AS base
RUN pnpm runtime set node 24 -g

FROM base AS build
COPY . /workspace
WORKDIR /workspace
RUN --mount=type=cache,id=pnpm,target=/var/cache/pnpm \
    pnpm install --store-dir /var/cache/pnpm --frozen-lockfile
RUN pnpm run -r build
RUN pnpm deploy --filter=api-gateway --prod /prod/api-gateway
RUN pnpm deploy --filter=flight --prod /prod/flight
RUN pnpm deploy --filter=document --prod /prod/document
RUN pnpm deploy --filter=web --prod /prod/web

FROM base AS api-gateway
COPY --from=build /prod/api-gateway /prod/api-gateway
WORKDIR /prod/api-gateway
EXPOSE 3000
CMD [ "pnpm", "start" ]

FROM base AS flight
COPY --from=build /prod/flight /prod/flight
WORKDIR /prod/flight
EXPOSE 3001
CMD [ "pnpm", "start" ]

FROM base AS document
COPY --from=build /prod/document /prod/document
WORKDIR /prod/document
EXPOSE 3002
CMD [ "pnpm", "start" ]


FROM nginxinc/nginx-unprivileged:${NGINX_VERSION} AS web

COPY nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx --from=build /workspace/apps/web/dist/ /usr/share/nginx/html/

USER nginx

EXPOSE 8080

ENTRYPOINT [ "nginx", "-c", "/etc/nginx/nginx.conf" ]

CMD [ "-g", "daemon off;" ]

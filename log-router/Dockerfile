FROM ghcr.io/jqlang/jq:1.8.1 AS jq

FROM public.ecr.aws/aws-observability/aws-for-fluent-bit:3

COPY --from=jq /jq /usr/local/bin/jq
COPY az-entrypoint.sh /az-entrypoint.sh


CMD ["/bin/sh", "/az-entrypoint.sh"]
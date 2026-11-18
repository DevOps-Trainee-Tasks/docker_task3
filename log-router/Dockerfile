FROM public.ecr.aws/aws-observability/aws-for-fluent-bit:3 AS fluentbit

FROM amazonlinux:2023

RUN dnf install -y jq && dnf clean all

COPY --from=fluentbit /fluent-bit /fluent-bit
COPY --from=fluentbit /ecs /ecs
COPY --from=fluentbit /entrypoint.sh /entrypoint.sh
COPY az-entrypoint.sh /az-entrypoint.sh

CMD ["/bin/sh", "/az-entrypoint.sh"]
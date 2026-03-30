ARG BASE_IMAGE=us-central1-docker.pkg.dev/votos-app-99/odoo/odoo19-enterprise:v1
FROM ${BASE_IMAGE}

USER root
RUN mkdir -p /mnt/extra-addons/github-addons
COPY ./addons /mnt/extra-addons/github-addons
RUN chown -R 101:101 /mnt/extra-addons/github-addons && \
   chmod -R 755 /mnt/extra-addons/github-addons

USER 101
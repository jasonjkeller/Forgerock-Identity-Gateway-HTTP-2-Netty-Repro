#
#  Copyright 2020-2024 ForgeRock AS. All Rights Reserved
#
#  Use of this code requires a commercial software license with ForgeRock AS.
#  or with one of its affiliates. All use shall be exclusively subject
#  to such license between the licensee and ForgeRock AS.
#
# =============================================================================================================
#  ForgeRock provides no commercial support for production deployments that use ForgeRock’s evaluation-only
#  Docker images.
#  When deploying the ForgeRock Identity Platform using Docker images, you must build and use your own images
#  for production deployments.
# =============================================================================================================
#
FROM gcr.io/forgerock-io/java-21:latest
#
# Default install directory for IG. Override this to set a different location.
#
ENV INSTALL_DIR /opt/ig

COPY --chown=forgerock:root . "${INSTALL_DIR}"
#
# Default home for IG config. Override this to set a different location.
#
ENV IG_INSTANCE_DIR /var/ig

RUN mkdir -p "${IG_INSTANCE_DIR}" \
    && chown -R forgerock:root "${IG_INSTANCE_DIR}" "${INSTALL_DIR}" \
    && chmod -R g+rwx "${IG_INSTANCE_DIR}" "${INSTALL_DIR}"

USER 11111

ENTRYPOINT ${INSTALL_DIR}/bin/start.sh ${IG_INSTANCE_DIR}

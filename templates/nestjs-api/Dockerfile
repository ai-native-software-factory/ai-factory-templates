ARG DOCKER_VERSION=20.10.16
ARG NODEJS_VERSION=20-alpine
ARG WORK_DIR=/script


FROM node:${NODEJS_VERSION} AS builds
ARG WORK_DIR
WORKDIR ${WORK_DIR}

ENV DOCKER_BUILD=true

ADD . ${WORK_DIR}/
RUN npm install --cache .npm --no-fund --no-audit --no-workspaces
RUN npm run build --no-workspaces


FROM node:${NODEJS_VERSION} AS package
ARG WORK_DIR
WORKDIR ${WORK_DIR}

ENV DOCKER_BUILD=true

ADD package.json package-lock.json .npmrc ${WORK_DIR}/
COPY --from=builds ${WORK_DIR}/.npm/ ${WORK_DIR}/.npm/
COPY --from=builds ${WORK_DIR}/node_modules/ ${WORK_DIR}/node_modules/

RUN npm install --cache .npm --no-fund --no-audit --no-workspaces --omit dev


FROM node:${NODEJS_VERSION} AS deploy
ARG WORK_DIR
WORKDIR ${WORK_DIR}

COPY --from=package ${WORK_DIR}/node_modules ${WORK_DIR}/node_modules
COPY --from=package ${WORK_DIR}/package.json ${WORK_DIR}/package-lock.json  ${WORK_DIR}/

COPY --from=builds ${WORK_DIR}/dist/apps/ ${WORK_DIR}/

EXPOSE 3000

ENTRYPOINT ["node"]
CMD ["dist/apps/default/main"]

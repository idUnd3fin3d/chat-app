# Frontend for [node-chat](https://github.com/yxxr1/node-chat)

## [Envs](src/config/common.ts):
- `API_URL`: api url, default `http://localhost:8080`
- `WS_URL`: api ws url, default `ws://localhost:8080/ws`
- `DEV_PORT`: dev server port, default 3000

## Start app:
- `npm i` to install deps
- `npm run serve` to start dev server

## Execute tests:
- `npm run test` to run jest tests
- `npm run test:e2e` to run e2e tests, need dev server and backend to be started locally

## CI/CD envs:
### App:
- `APP_API_URL_PROD`: app [API_URL](README.md:4), prod env
- `APP_API_URL_DEV`: app [API_URL](README.md:4), dev env
- `APP_WS_URL_PROD`: app [WS_URL](README.md:5), prod env
- `APP_WS_URL_DEV`: app [WS_URL](README.md:5), dev env
- `K8S_REPLICAS_COUNT_PROD`: k8s replicas count, prod env
- `K8S_REPLICAS_COUNT_DEV`: k8s replicas count, dev env
- `K8S_INGRESS_DOMAIN`: frontend domain

### Global:
- `DOCKER_REGISTRY_HOST`: Docker registry host
- `DOCKER_AUTH_CONFIG`: Docker auth config
    ```bash
    DOCKER_REGISTRY_HOST="<HOST>"
    DOCKER_USERNAME="<USERNAME>"
    DOCKER_PASSWORD="<PASSWORD>"
    cat <<EOF | tr -d '\n '
    {
      "auths": {
          "$DOCKER_REGISTRY_HOST": {
            "auth": "$(echo -n "$DOCKER_USERNAME:$DOCKER_PASSWORD" | base64)"
        }
      }
    }
    EOF
    ```
- `K8S_DOCKER_REGISTRY_SECRET_NAME`: Docker registry k8s secret name
- `K8S_INGRESS_NAME`: k8s ingress name\
- `K8S_NAMESPACE_DEV`: k8s namespace for dev env
- `K8S_NAMESPACE_PROD`: k8s namespace for prod env
- `K8S_CONFIG`: base64 encoded kube config file
    ```bash
    cat kube_config_file | base64 | tr -d '\n'
    ```
- `DEV_BRANCH_NAME`: dev branch name
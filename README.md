# Home Server Helm

Run `./scripts/deploy.sh`

It will save a list of hashes as an annotation in the master node. It will use that to determine which services, if any, to redeploy. If a single values files changes it will only redeploy that service. If a templates file changes it will redeploy all services.

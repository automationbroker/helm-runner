Helm Runner
==========

Implement the Automation Broker's [Service Bundle
Contract](https://github.com/openshift/ansible-service-broker/blob/master/docs/service-bundle.md)
with a runner capable of installing, updating, and deleting Helm Charts. See the [Helm Chart Repository
Proposal](https://github.com/openshift/ansible-service-broker/blob/master/docs/proposals/helm-charts.md)
for more information.

While we continue to investigate the idea of a Service Bundle and the
underlying contract, it is useful to have working examples. This image is
intended, primarily, to be used as the runner of a `helm` type registry in the
[Automation Broker's
Config](https://github.com/openshift/ansible-service-broker/blob/master/docs/config.md).
For example:

```yaml
registry:
  - name: stable
    type: helm
    url: "https://kubernetes-charts.storage.googleapis.com"
    runner: "docker.io/automationbroker/helm-runner:latest"
    white_list:
      - ".*"
```

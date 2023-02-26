# open policy agent gatekeeper 

The Open Policy Agent [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/) can be leveraged to help enforce policies and strengthen governance in your Kubernetes environment. Gatekeeper also provide [library](https://open-policy-agent.github.io/gatekeeper-library/website/allowedrepos) containing variety of examples.


## Basics

### Policy Types
* <b>Privileged:</b>  open and unrestricted
* <b>Baseline:</b> Covers most common known privilege escalations and provides an easier onboarding
* <b>Restricted:</b> Highly restricted, covering best practices. May cause compatibility issues

Each of these policies define which fields are restricted within a Pod specification and the allowed values. Some of the following fields are restricted by the policies:

```
spec.containers[*].ports
spec.volumes[*].hostPath
spec.securityContext
spec.containers[*].securityContext
```

### Policy Modes
* <b>enforce:</b> Any Pods that violate the policy will be rejected
* <b>audit:</b> Pods with violations will be allowed and an audit annotation will be added
* <b>warn:</b> Pods that violate the policy will be allowed and a warning message will be sent back to the user.

```
resource "helm_release" "gatekeeper_system" {
  count = var.gatekeeper_enabled ? 1 : 0

  name       = "gatekeeper"
  namespace  = local.gatekeeper_namespace
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  timeout    = 3600
  wait       = true

  values = [
    jsonencode({
      postUpgrade = {
        labelNamespace = {
          podSecurity = [
            "pod-security.kubernetes.io/audit=restricted",
            "pod-security.kubernetes.io/audit-version=latest",
            "pod-security.kubernetes.io/warn=restricted",
            "pod-security.kubernetes.io/warn-version=latest"
          ]
        }
      }
      postInstall = {
        labelNamespace = {
          podSecurity = [
            "pod-security.kubernetes.io/audit=restricted",
            "pod-security.kubernetes.io/audit-version=latest",
            "pod-security.kubernetes.io/warn=restricted",
            "pod-security.kubernetes.io/warn-version=latest"
          ]
        }
      }
      upgradeCRDs = {
        enabled = false
      }
    })
  ]
}

```

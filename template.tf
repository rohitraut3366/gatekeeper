locals {
  namespace = "gatekeeper-system"
}

resource "kubernetes_manifest" "constraint_template" {
  manifest = {
    "apiVersion" : "templates.gatekeeper.sh/v1",
    "kind" : "ConstraintTemplate",
    "metadata" : {
      "name" : "k8sallowedrepos",
      "annotations" : {
        "metadata.gatekeeper.sh/title" : "Allowed Repositories",
        "metadata.gatekeeper.sh/version" : "1.0.0",
        "description" : "Requires container images to begin with a string from the specified list."
      }
    },
    "spec" : {
      "crd" : {
        "spec" : {
          "names" : {
            "kind" : "K8sAllowedRepos"
          },
          "validation" : {
            "openAPIV3Schema" : {
              "type" : "object",
              "properties" : {
                "repos" : {
                  "description" : "The list of prefixes a container image is allowed to have.",
                  "type" : "array",
                  "items" : {
                    "type" : "string"
                  }
                }
              }
            }
          }
        }
      },
      "targets" : [
        {
          "target" : "admission.k8s.gatekeeper.sh",
          "rego" : "package k8sallowedrepos\n\nviolation[{\"msg\": msg}] {\n  container := input.review.object.spec.containers[_]\n  satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]\n  not any(satisfied)\n  msg := sprintf(\"container <%v> has an invalid image repo <%v>, allowed repos are %v\", [container.name, container.image, input.parameters.repos])\n}\n\nviolation[{\"msg\": msg}] {\n  container := input.review.object.spec.initContainers[_]\n  satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]\n  not any(satisfied)\n  msg := sprintf(\"initContainer <%v> has an invalid image repo <%v>, allowed repos are %v\", [container.name, container.image, input.parameters.repos])\n}\n\nviolation[{\"msg\": msg}] {\n  container := input.review.object.spec.ephemeralContainers[_]\n  satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]\n  not any(satisfied)\n  msg := sprintf(\"ephemeralContainer <%v> has an invalid image repo <%v>, allowed repos are %v\", [container.name, container.image, input.parameters.repos])\n}\n"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "constraint" {
  manifest = {
    "apiVersion" : "constraints.gatekeeper.sh/v1beta1",
    "kind" : "K8sAllowedRepos",
    "metadata" : {
      "name" : "repo-is-openpolicyagent"
    },
    "spec" : {
      "match" : {
        "kinds" : [
          {
            "apiGroups" : [""],
            "kinds" : ["Pod"]
          }
        ],
        "namespaces" : ["default"]
      },
      "parameters" : {
        "repos" : ["388418451245.dkr.ecr.us-west-2.amazonaws.com/"]
      }
    }
  }
  depends_on = [
    kubernetes_manifest.constraint_template
  ]
}




resource "kubernetes_manifest" "constraint_template" {
  manifest = {
    "apiVersion" : "templates.gatekeeper.sh/v1",
    "kind" : "ConstraintTemplate",
    "metadata" : {
      "name" : "k8sallowedrepos",
      "annotations" : {
        "metadata.gatekeeper.sh/title" : "Allowed Repositories",
        "metadata.gatekeeper.sh/version" : "1.0.0",
        "description" : "Requires container images to begin with a string from the specified list."
      }
    },
    "spec" : {
      "crd" : {
        "spec" : {
          "names" : {
            "kind" : "K8sAllowedRepos"
          },
          "validation" : {
            "openAPIV3Schema" : {
              "type" : "object",
              "properties" : {
                "repos" : {
                  "description" : "The list of prefixes a container image is allowed to have.",
                  "type" : "array",
                  "items" : {
                    "type" : "string"
                  }
                }
              }
            }
          }
        }
      },
      "targets" : [
        {
          "target" : "admission.k8s.gatekeeper.sh",
          "rego" : <<EOT
          package k8sallowedrepos
          
          violation[{"msg": msg}] {
            container := input.review.object.spec.containers[_]
            satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]
            not any(satisfied)
            msg := sprintf("container <%v> has an invalid image repo <%v>, allowed repos are %v", [container.name, container.image, input.parameters.repos])
          }

          violation[{"msg": msg}] {
            container := input.review.object.spec.initContainers[_]
            satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]
            not any(satisfied)
            msg := sprintf("initContainer <%v> has an invalid image repo <%v>, allowed repos are %v", [container.name, container.image, input.parameters.repos])
          }

          violation[{"msg": msg}] {
            container := input.review.object.spec.ephemeralContainers[_]
            satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]
            not any(satisfied)
            msg := sprintf("ephemeralContainer <%v> has an invalid image repo <%v>, allowed repos are %v", [container.name, container.image, input.parameters.repos])
          }
          
          EOT
          }
      ]
    }
  }
}


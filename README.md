![docker pulls](https://img.shields.io/docker/pulls/djordjeparovic/doks-cert-to-pipeline-env.svg)

# Foreword
This project is in very early stage and you can use it at your own risk only. It does not implement any security measures, but completely relies on your security setup.

# What's this all about?

It's about updating CI (Bitbucket only for now) pipeline env variables with DOKS (Digital Ocean Kubernetes) valid certificate, as managed certificate expire every 7 days.

If you want to configure CI pipeline to deploy resources to DOKS, and you are using Kubernetes certificate in pipeline env variable, you will need a way to keep that certificate fresh. Otherwise, every 7 days your pipeline will fail with error unauthorized to DOKS.

# How this works?

It's just a CronJob you create in your DOKS. It will run every 2 days and update your CI pipeline env variable, thus pipeline will be cleared to work properly.

# How to use it?

In your DOKS, to the desired namespace create a CronJob like that:

```
wget https://raw.githubusercontent.com/djordjeparovic/doks-cert-to-pipeline-env/master/manifests/cronjob-doks-cert-to-pipeline-env.yml
# update env variables (replace CHANGE-ME) in cronjob-doks-cert-to-pipeline-env.yaml
kubectl apply -f cronjob-doks-cert-to-pipeline-env.yaml
```

# How to contribute?

Just create a PR or open an issue. Contributions are welcome! Since this tool is rather simple, it will be replaced with some better solution most likely very soon.

If you know how to do that and it's possible to automate it all using Terraform I'm more than happy to buy you a coffee!

# Variables
| Variable name             | Description                                                                                                                          | Example value                                                      |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| CODE_COLLABORATION_TOOL   | The only supported value is "bitbucket"                                                                                              | "bitbucket"                                                        |
| DIGITALOCEAN_ACCESS_TOKEN | API token from DO.  Needs only Read access. https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/            | "c2656fca60eb7d9abd01a06fe815655c07351fc726ef8cc10815347ad08091ad" |
| BITBUCKET_USERNAME        | Username you use to login to Bitbucket.                                                                                              | "me@example.com"                                                   |
| BITBUCKET_PASSWORD        | Password you use to login to Bitbucket.                                                                                              | "myt0ps3cretpass$"                                                 |
| BITBUCKET_TEAM            | From your repository url you can see it - https://bitbucket.org/<BITBUCKET_TEAM>/myapp                                               | "mycompany"                                                        |
| REPO_SLUG                 | From your repository url you can see it - https://bitbucket.org/mycompany/<REPO_SLUG>                                                | "myapp"                                                            |
| VARIABLE_NAME             | Name of Bitbucket variable you want to update. Caution! Old value will be lost!                                                      | "KUBECONFIG"                                                       |
| VARIABLE_PROTECTED        | Is variable marked as "secured". Highly recommeneded.                                                                                | "true"                                                             |
| DOKS_NAME                 | Name of Kubernetes cluster on DO. When you open https://cloud.digitalocean.com/kubernetes/clusters?i=<CLUSTER_ID> you will see that. | "production-cluster"                                               |
| VERBOSE                   | Brings debugging output to the container logs. Don't enable it unless needed, it discloses very sensitive data to logs.              | "false"                                                            |



# aa-jenkins-scripts

<p align="center">
  <img src=".github/logo.png" alt="aa-jenkins-scripts logo" width="128" />
</p>

## Setup

You'll need to create a

- jenkins token
- GitLab token

Create jenkins creds file

```text
$ cat ~/.bashrc.d/jenkins_creds.sh
export JENKINS_CREDS=daoneill:119e18ebxxxxxxxxxxxx6a9104
```

Create GitLab creds file

```text
$ cat ~/.bashrc.d/gitlab-token.sh
export GITLAB_TOKEN=E2K7RzcxxxxxxxxxkKsbrER
```

## Jenkins start

Start and run the latest commit

```text
./jenkins-start.sh
```

Start and run a specific commit

```text
./jenkins-start.sh SHA1
```

## Run a range of commits

SHA1_FROM should be older than SHA1_TO

```text
./jenkins-range.sh SHA1_FROM SHA1_TO
```

## Clean up namespaces

This will clear ours and jenkins requester namespaces

```text
./jenkins-release.sh
```

## Expected output

Something a long the lines of

```text
Waiting for queue item to be scheduled as a job ..

 >> https://ci.int.devshift.net/job/automation-analytics-ephemeral/263/consoleText

Waiting for the namespace to be determined in the build .....
Now using project "ephemeral-8o2fpm" on server "https://api.c-rh-c-eph.8p0c.p1.openshiftapps.com:6443".

Waiting for the consoledot URL ..

 >> https://console-openshift-console.apps.c-rh-c-eph.8p0c.p1.openshiftapps.com/k8s/cluster/projects/ephemeral-8o2fpm

Waiting for the UI URL ...................

Project / Namespace

 >> export NAMESPACE=ephemeral-8o2fpm
 >> export BONFIRE_NS_REQUESTER=automation-analytics-ephemeral-263

Waiting for finished ..................................................Deleting this reservation will also delete the associated namespace.
```

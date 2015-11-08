# `bosh rsync blobs`

# Motivation

`bosh sync blobs` takes a long time on a new workstation because there is a lot of stuff to download. The local network is usually way faster than the internet, and other workstations on the same network may have almost all blobs we need. Sharing blobs locally makes sense; doing it manually sucks. Let's automate this.

# User Story

> As a developer of a BOSH-deployed software release, I would like to sync blobs with a server on the local network, so that blobs are downloaded as fast as the local network connection allows instead of being constrained by the the bandwidth of my internet connection.

# Goals

rsync `$PROJECT/.blobs` from a shared rsync server to the developer workstation, so that the price for downloading a blob from the internet is only paid once. Newly downloaded files are contributed back to the shared rsync server.

# Anti-Goals

Don't break how `bosh sync blobs` works.

# Principle

* BOSH symlinks a blob correctly if the symbolic name is not present in `blobs`, but the target is present in `.blobs`. Therefore, we only need to rsync `.blobs` and `bosh sync blobs` will do the right thing afterwars.

* We assume that there is a shared rsync server on the local network where we have access to

* A script does something like along these lines:

  ```
  cd ~/workspace/cf-release
  rsync $BLOB_HOST/$PROJECT .blobs
  bosh sync blobs
  rsync .blobs $BLOB_HOST/$PROJECT
  ```

* Add some basic checks that prevents people from shooting themselves in the foot (like an accidental `rsync --delete`)

# Implementation

* Sample rsync call

  ```
  rsync          \
      -e ssh     \
      --verbose  \
      --stats    \
      --progress \
      --archive  \
    $BLOB_HOST:$PROJECT/.blobs/ \
    .blobs/
  ```
* Write it as a bosh cli plugin ([Dr. Nic](https://github.com/drnic) has a few examples)
* Might as well be a BASH script (has to be on the `$PATH`)
* May be a wrapper around bosh that captures `sync blobs` (like [hub](https://github.com/github/hub) does)

## Variables

* `$PROJECT` is either read via BOSH or the name of the current project directory. It may be worth using a scheme-less URL for `$PROJECT`, e.g. `github.com/cloudfoundry/cf-release` so that we get namespacing like golang has for `go get`.
* Do not mix blobs across projects, otherwise everyone fetches blobs of all projects. Use at least the project name as rsync project to keep things separate.
* Publish the rsync sever config script in a separate (public) repo so that everyone can deploy it

## Choices for rsync servers

* Server deployed (e.g. via Ansible or similar) to a private host
  * Simple
  * How do we know the host name if there is no static host name / IP?

* Shared server
  * May already exist in your corporate universe
  * Might have bandwidth constraints that are prohibiting to use it
  * May not allow individual projects
  * May not allow anonymous up- and downloads

* Dedicated VM
  * Not so simple anymore
  * Might have bandwidth constraints that are prohibiting its use

* Docker container
  * Not so simple anymore
  * Might have bandwidth constraints that are prohibiting to use it

* BOSH release so that it can be deployed standalone or spiffed into a concourse deployment
  * Not so simple anymore
  * Good fit for someone already runnign stuff under BOSH

# Questions

* Should everyone upload their stuff once a new download is complete, so that the server stays fresh? Probably yes.
* How do we clean up the server and remove obsolete files? We shouldn't let users delete, probably.
* Is a (caching) HTTP proxy a better way to solve this?

# Meta

This is an experiment on running a proposal. Instead of writing a Google doc, we write the README directly and collaborate publically using Github's commenting on PRs.

Work flow:

1. Create a public Github project
1. Add an empty README to it
1. Commit and push
1. Create a branch and write the proposal as an update to the README
1. Push and create a PR
1. Send RFQ to interested parties and ask for comments on the PR.

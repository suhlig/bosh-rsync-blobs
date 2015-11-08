# `bosh rsync blobs`

# User Story

  As a developer of a BOSH-deployed software release, I would like to download BLOBs from a local server, so that instead of being constrained by the internet connection, `bosh sync blobs` runs as fast as the local network allows.

The local network is faster than the internet. Let's rsync $PROJECT/.blobs from a shared server to the developer workstation, so that only the first person pays the price for downloading from the internet.

BOSH symlinks a blob correctly if the symbloic name is not present in `blobs`, but the target is present in `.blobs`. Therefore, we only need to sync `.blobs` and `bosh sync blobs` will do the right thing.

# Principle

* There is a shared rsync server where everyone has read access (and some or all may have write access) to an rsync server

* A script does something like this:

        ```
        cd ~/workspace/cf-release
        rsync $BLOB_HOST/$PROJECT .blobs
        bosh sync blobs
        rsync .blobs $BLOB_HOST/$PROJECT
        ```

* We add some basic checks that prevents people from shooting themselves in the foot (like `--delete`)

# Implementation

* Sample rsync call

        rsync          \
            -e ssh     \
            --verbose  \
            --stats    \
            --progress \
            --archive  \
          $BLOB_HOST:cf-release/.blobs/ \
          .blobs/

* Write it as a bosh cli plugin ([Dr. Nic](https://github.com/drnic) has a few examples)
* Might as well be a BASH script (has to be on the `$PATH`)
* May be a wrapper around bosh that captures `sync blobs` (like [hub](https://github.com/github/hub) does)

## Variables

* `$BLOB_HOST` comes from `$BOSH_BLOBSTORE_RSYNC_URL` or a (sensible) default
* `$PROJECT` is either read from BOSH or the name of the current project. It may be worth using a scheme-less URL for `$PROJECT`, e.g. `github.com/cloudfoundry/cf-release` so that we get namespacing like go.
* Do not mix blobs across project, otherwise everyone fetches blobs of all projects. Use at least the project name as rsync project to keep things separate.
* Keep the rsync sever config script in a separate (public) repo so that everyone can deploy it

## Choices for deploying a server

* Rsync server deployed (e.g. via Ansible or similar) to a private host
  * Simple
  * How do we know the host name if there is no static host name / IP?
* Shared rsync server
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

* Should everyone upload their stuff once the download was done, so that the server stays fresh? Probably yes.
* How do we clean up the server? We shouldn't let users delete, maybe.
* Is a (caching) HTTP proxy a better way to solve this?

# Meta

This is an experiment on running a proposal. Instead of writing a Google doc, we write the README directly and collaborate publically using Github's commenting on PRs.

Work flow:

1. Create a public Github project
1. Add an empty README to it
1. Commit and push
1. Create a branch and write the proposal as an update to the README
1. Push and create a PR
1. Send RFQ to interested parties and ask for comments on the PR. Mail is fine, too, but comments on the PR are preferred.

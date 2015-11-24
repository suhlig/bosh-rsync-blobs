* Chop off trailing slash from $RSYNC_URL if it exists
* Set up travis ci
* Ignore rsync temp files like .191c06d332f76443a45519cdfd3634c6b95cbd1f.OZs7al
* How do we garbage-collect old blobs? Can't access atime via rsync ...
* What if the project directory does not exist? Can we check for it, and maybe create it?
* Get a preview of that you'd get if syncing (--dry-run)
* Namespacing by git remote

        git config --get remote.origin.url | sed "s/https:\/\///g" | sed "s/.git//g" | sed "s/http:\/\///g"

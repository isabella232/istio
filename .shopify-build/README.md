# Building an Istio version

* Make sure that this repo is up to date with https://github.com/istio/istio
  master:

```
# If you don't already have this repo locally, clone it
dev clone istio

# Add istio/istio as a remote
git remote add upstream git@github.com:istio/istio.git

# Housekeeping - update from upstream and update the repo
git fetch upstream
git checkout master
git merge upstream/master
git push

# Choose which release to start from, e.g. 1.1.6
git checkout <release tag>

# Create a new branch - make sure to include the version and an indication of
# what non-upstream changes are included (if possible) - 
# e.g. 1.1.6-hardcoded-max-conns
git checkout -b <new-branch-name>

# Cherry pick the commit which adds this .shopify-build folder.
# This will be the HEAD commit on https://github.com/Shopify/istio/tree/shopify-build
git cherry-pick <.shopify-build commit>

# Cherry pick any necessary commits that haven't been merged in upstream, or
# make any modifications to Istio here
git cherry-pick <SHAs of needed alterations>

# Tag the branch. Branch name and tag name can't be the same, so use
# a shopify/* prefix e.g. shopify/1.1.4
git tag <tag>

git push
git push tag <tag>
```

Once this is done, you will need to trigger a build manually via the Buildkite
UI, passing in the branch name.

When done, [set the default branch on GitHub](https://github.com/Shopify/istio/settings/branches) to the branch that will be running in production.

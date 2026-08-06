71-install-git-compact
======================

Title:    git-compact -- compacts and prunes local git repositories (gc, reflog expire, repack)
Method:   curl one-liner from https://raw.githubusercontent.com/alimtvnetwork/git-compact/{tag}/install.sh
Deps:     git, curl
Target:   ~/.local/bin/git-compact
Verify:   git-compact --version
Usage:    ./run.sh [install|check|repair|uninstall] [--tag <ref>] [--help]

Ref pinning precedence: --tag flag > $GIT_COMPACT_TAG > config install.releaseTag > main
Numeric refs (1.2.0) are normalised to v1.2.0.

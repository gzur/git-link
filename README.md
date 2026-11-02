# git-link
Open a repo's GitHub / GitLab page from its `origin` remote.

## Installation

1. Clone the repo
2. Symlink the zsh script onto your PATH:
   ```shell
   ln -s /path/to/git-link/git-link.zsh ~/.local/bin/git-link
   ```
3. In a git repo, run `git link`

## Usage

```
git link        the repo
git link b      the current branch
git link m      merge/pull requests (on a branch: the ones from this branch)
git link p      alias of m
git link a      CI: GitHub Actions, GitLab pipelines
git link d      container registry
git link l      copy the repo URL to the clipboard
git link u      print the URL, open nothing
git link -h     help
```

Any host other than github.com is treated as GitLab. Run `./test.zsh` for the tests.

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ "$(git branch --show-current)" != "main" ]]; then
  echo "Release must be created from the main branch." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to release with a dirty worktree. Commit or stash changes first." >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Git remote 'origin' is not configured." >&2
  exit 1
fi

current_version="$(awk '$1 == "version:" { print $2; exit }' pubspec.yaml)"
if [[ ! "$current_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  echo "Unsupported pubspec version '$current_version'; expected MAJOR.MINOR.PATCH+BUILD." >&2
  exit 1
fi

major=$((10#${BASH_REMATCH[1]}))
minor=$((10#${BASH_REMATCH[2]}))
patch=$((10#${BASH_REMATCH[3]} + 1))
build=$((10#${BASH_REMATCH[4]} + 1))
new_version="${major}.${minor}.${patch}+${build}"
tag="v${major}.${minor}.${patch}"

if git show-ref --verify --quiet "refs/tags/$tag"; then
  echo "Tag '$tag' already exists locally." >&2
  exit 1
fi

remote_tag="$(git ls-remote --tags origin "refs/tags/$tag")"
if [[ -n "$remote_tag" ]]; then
  echo "Tag '$tag' already exists on origin." >&2
  exit 1
fi

temporary_pubspec="$(mktemp "${TMPDIR:-/tmp}/pubspec.yaml.XXXXXX")"
trap 'rm -f "$temporary_pubspec"' EXIT
awk -v version="$new_version" '
  BEGIN { updated = 0 }
  $1 == "version:" && !updated {
    print "version: " version
    updated = 1
    next
  }
  { print }
  END {
    if (!updated) {
      print "pubspec.yaml has no top-level version field." > "/dev/stderr"
      exit 1
    }
  }
' pubspec.yaml > "$temporary_pubspec"
mv "$temporary_pubspec" pubspec.yaml
trap - EXIT

git add pubspec.yaml
git commit -m "chore: release $tag"
git tag "$tag"
git push origin main --tags

echo "Released $tag (pubspec version $new_version)."

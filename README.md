# Generate Version Action

Generate semantic versions based on git tags and release type with intelligent auto-detection.

## Usage

```yaml
- name: Generate version
  id: version
  uses: jdfalk/generate-version-action@v1
  with:
    release-type: auto
    branch-name: ${{ github.ref_name }}
    prerelease-suffix: ""

- name: Create release
  uses: softprops/action-gh-release@v1
  with:
    tag_name: ${{ steps.version.outputs.tag }}
    name: Release ${{ steps.version.outputs.version }}
```

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `release-type` | Release type (major/minor/patch/auto) | `auto` |
| `branch-name` | Git branch name for context | `main` |
| `prerelease-suffix` | Prerelease suffix (alpha/beta/rc) | `` |

## Outputs

| Output | Description |
|--------|-------------|
| `tag` | Full semantic version tag (v1.2.3) |
| `version` | Semantic version without 'v' (1.2.3) |
| `major` | Major version number |
| `minor` | Minor version number |
| `patch` | Patch version number |
| `prerelease` | Prerelease suffix if any |

## Release Types

### Semantic Versioning

- **major**: X.0.0 - Breaking API changes
- **minor**: x.Y.0 - New features, backward compatible
- **patch**: x.y.Z - Bug fixes only
- **auto**: Detect from commit messages (uses minor if `feat:` commits found, else patch)

## Examples

### From tag v1.2.3 with patch release

```yaml
- uses: jdfalk/generate-version-action@v1
  id: version
  with:
    release-type: patch

# Output:
# tag=v1.2.4
# version=1.2.4
# major=1 minor=2 patch=4
```

### From tag v1.2.3 with prerelease suffix

```yaml
- uses: jdfalk/generate-version-action@v1
  id: version
  with:
    release-type: minor
    prerelease-suffix: "beta"

# Output:
# tag=v1.3.0-beta.1
# version=1.3.0-beta.1
```

### Auto-detect from commits

```yaml
- uses: jdfalk/generate-version-action@v1
  id: version
  with:
    release-type: auto
    # Looks for 'feat:' commits since last tag
    # If found → minor, else → patch
```

## Features

✅ **Semantic Versioning** - SemVer 2.0.0 compliant
✅ **Auto-Detection** - Detect type from commit messages
✅ **Prerelease Support** - Generate alpha/beta/rc versions
✅ **Git Native** - Uses git tags as source of truth
✅ **Component Output** - Individual version numbers available

## Commit-Based Auto-Detection

When `release-type: auto`, the action scans commits since the last tag:

- **Minor bump** (x.Y.0): If any commit starts with `feat:` or `feature:`
- **Patch bump** (x.y.Z): Otherwise

Enable with conventional commit prefix like:

```
feat(api): add new endpoint
fix(docs): update readme
```

## Related Actions

- [release-strategy-action](https://github.com/jdfalk/release-strategy-action) - Determine release strategy
- [detect-languages-action](https://github.com/jdfalk/detect-languages-action) - Detect project languages

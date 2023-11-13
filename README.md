# rules_endor

Bazel rules for [Endor Labs](https://app.endorlabs.com/login). Documentation for Endor Labs can be found [here](https://docs.api.endorlabs.com)

## Status

This module is in beta, but we may make a few changes as we gather feedback from early adopters.

## Setup

Include the following snippet in the Workspace file to setup `rules_endor`. Refer to [release notes](https://github.com/endorlabs/rules_endor/releases) for setup instructions of a specific version.

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_endor",
    sha256 = "b7a2ae4f82b267241ca94ca15369f3039e80b37a8245801667a685fe29939a35",
    strip_prefix = "rules_endor-1.0.0",
    urls = [
        "https://github.com/endorlabs/rules_endor/archive/refs/tags/v1.0.0.tar.gz",
    ],
)

load("@rules_endor//endorctl:repositories.bzl", "rules_endorctl_toolchains")
rules_endorctl_toolchains(version = "1.6.35")
```

## Development

The repository follows the [official recommendation](https://bazel.build/rules/deploying) on deploying bazel rules.
All the rule definitions are in [endorctl/internal](endorctl/internal).

## FAQ

If you are facing the following error

```
ERROR: java.io.IOException: Error downloading [https://api.endorlabs.com/meta/version] to /private/var/tmp/_bazel_foo/0563020d664d3a0e3f604548899f60ef/external/rules_endorctl_toolchains/versions.json: extension (5) should not be presented in certificate_request
```

Add the following flag in your `.bazelrc`

```
startup --host_jvm_args="-Djdk.tls.client.protocols=TLSv1,TLSv1.1,TLSv1.2"
```
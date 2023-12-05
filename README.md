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
rules_endorctl_toolchains()
```

## Rules

You have two choices to use `endorctl` through the bazel rule, either by using the CLI directly or by using the endor rules.

```
bazel run @rules_endorctl_toolchains//:endorctl -- --help
```

or

```starlark
load("@rules_java//java:defs.bzl", "java_binary")
load("@rules_endor//endorctl:defs.bzl", "endorctl_scan")

package(default_visibility = ["//visibility:public"])

java_library(
    name = "java-maven-lib",
    srcs = glob([
        "src/main/java/com/example/myproject/App.java",
    ]),
    deps = [
        "@maven//:com_google_code_findbugs_jsr305",
        "@maven//:com_google_errorprone_error_prone_annotations",
        "@maven//:com_google_j2objc_j2objc_annotations",
        "@maven//:org_checkerframework_checker_qual",
        "@maven//:org_codehaus_mojo_animal_sniffer_annotations",
        "@maven//:org_apache_commons_commons_text",
    ],
)

endorctl_scan(
    name = "endorctl-scan",
    targets = [
        ":java-maven-lib-test",
    ],
    scan_args = [
        "--namespace=test_namespace"
    ],
)
```

Running the rules:

```bash
bazel test --test_env=ENDOR_TOKEN --test_output=all --test_env=ENDOR_SCAN_PATH=$(pwd) --test_env=HOME --sandbox_writable_path=$HOME/.endorctl //examples/java:endorctl-scan
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
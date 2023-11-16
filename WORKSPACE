workspace(name = "rules_endor")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

bazel_skylib_version = "1.1.1"
http_archive(
    name = "bazel_skylib",
    sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/{version}/bazel-skylib-{version}.tar.gz".format(version = bazel_skylib_version),
        "https://github.com/bazelbuild/bazel-skylib/releases/download/{version}/bazel-skylib-{version}.tar.gz".format(version = bazel_skylib_version),
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()

load("//endorctl:repositories.bzl", "rules_endorctl_toolchains")
rules_endorctl_toolchains()
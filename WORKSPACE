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

RULES_JVM_EXTERNAL_TAG = "4.3"
RULES_JVM_EXTERNAL_SHA = "6274687f6fc5783b589f56a2f1ed60de3ce1f99bc4e8f9edef3de43bdf7c6e74"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "com.google.code.findbugs:jsr305:3.0.2",
        "com.google.errorprone:error_prone_annotations:2.11.0",
        "com.google.j2objc:j2objc-annotations:1.3",
        "org.codehaus.mojo:animal-sniffer-annotations:1.20",
        "org.checkerframework:checker-qual:3.12.0",
        "org.apache.commons:commons-text:1.10.0",
        "junit:junit:4.13.2",
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)
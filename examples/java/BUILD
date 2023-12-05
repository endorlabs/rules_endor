load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")
load("//endorctl:defs.bzl", "endorctl_scan")

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

java_test(
    name = "java-maven-test",
    srcs = glob(["src/test/java/com/example/myproject/*.java"]),
    test_class = "com.example.myproject.TestApp",
    deps = [
        ":java-maven-lib",
        "@maven//:junit_junit",
    ]
)

endorctl_scan(
    name = "endorctl-scan",
    targets = [
        ":java-maven-test",
    ],
    scan_args = [
        "--namespace=alex",
    ],
)

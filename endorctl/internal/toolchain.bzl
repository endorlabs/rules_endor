"""Endorctl toolchains macros to declare and register toolchains"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_BUILD_FILE = """
load(":toolchain.bzl", "declare_endorctl_toolchains")

package(default_visibility = ["//visibility:public"])

declare_endorctl_toolchains(
    os = "{os}",
    cpu = "{cpu}",
    rules_endorctl_repo_name = "{rules_endorctl_repo_name}",
 )
"""

_TOOLCHAINS_REPO = "rules_endorctl_toolchains"

_TOOLCHAIN_FILE = """
def _endorctl_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        cli = ctx.executable.cli,
    )
    return [toolchain_info]

_endorctl_toolchain = rule(
    implementation = _endorctl_toolchain_impl,
    attrs = {
        "cli": attr.label(
            doc = "The endorctl cli",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
    },
)

def declare_endorctl_toolchains(os, cpu, rules_endorctl_repo_name):
    for cmd in ["endorctl"]:
        ext = ""
        if os == "windows":
            ext = ".exe"
        toolchain_impl = cmd + "_toolchain_impl"
        _endorctl_toolchain(
            name = toolchain_impl,
            cli = str(Label("//:"+ cmd)),
        )
        native.toolchain(
            name = cmd + "_toolchain",
            toolchain = ":" + toolchain_impl,
            toolchain_type = "@{}//endorctl/tools/{}:toolchain_type".format(rules_endorctl_repo_name, cmd),
            exec_compatible_with = [
                "@platforms//os:" + os,
                "@platforms//cpu:" + cpu,
            ],
        )

"""

# Copied from rules_go: https://github.com/bazelbuild/rules_go/blob/bd44f4242b46e73fb2a81fc87ea4b52173bde84e/go/private/sdk.bzl#L240
#
# NOTE: This doesn't check for windows/arm64
def _detect_host_platform(ctx):
    if ctx.os.name == "linux":
        goos, goarch = "linux", "amd64"
        res = ctx.execute(["uname", "-p"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname == "s390x":
                goarch = "s390x"
            elif uname == "i686":
                goarch = "386"

        # uname -p is not working on Aarch64 boards
        # or for ppc64le on some distros
        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname == "aarch64":
                goarch = "arm64"
            elif uname == "armv6l":
                goarch = "arm"
            elif uname == "armv7l":
                goarch = "arm"
            elif uname == "ppc64le":
                goarch = "ppc64le"

        # Default to amd64 when uname doesn't return a known value.

    elif ctx.os.name == "mac os x":
        goos, goarch = "macos", "amd64"

        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname == "arm64":
                goarch = "arm64"

        # Default to amd64 when uname doesn't return a known value.

    elif ctx.os.name.startswith("windows"):
        goos, goarch = "windows", "amd64"
    elif ctx.os.name == "freebsd":
        goos, goarch = "freebsd", "amd64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)

    return goos, goarch

def _endorctl_download_releases_impl(ctx):
    version = ctx.attr.version
    repository_url = ctx.attr.repository_url

    if not version:
        ctx.report_progress("Finding latest endorctl version")

        ctx.download(
            url = "{}/meta/version".format(repository_url),
            output = "versions.json",
        )
        versions_data = ctx.read("versions.json")
        version = json.decode(versions_data)
        version = version["ClientVersion"]
        version = version[1:]

    os, cpu = _detect_host_platform(ctx)
    if os not in ["linux", "macos", "windows"] or cpu not in ["arm64", "amd64"]:
        fail("Unsupported operating system or cpu architecture ")
    if os == "linux" and cpu == "arm64":
        cpu = "aarch64"
    if cpu == "amd64":
        cpu = "x86_64"

    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))
    ctx.file("toolchain.bzl", _TOOLCHAIN_FILE)

    output = "endorctl"
    if os == "windows":
        output += ".exe"

    endor_cpu = cpu
    if cpu == "x86_64":
        endor_cpu = "amd64"

    bin = "endorctl_v{}_{}_{}".format(version, os, endor_cpu)

    ctx.report_progress("Finding sha of endorctl")
    ctx.download(
        url = "{}/meta/version/v{}".format(repository_url, version),
        output = "sha256s.json",
    )
    sha256s_data = ctx.read("sha256s.json")
    sha256s = json.decode(sha256s_data)["ClientChecksums"]

    sum = sha256s["ARCH_TYPE_LINUX_AMD64"]
    if os == "macos" and cpu == "x86_64":
        sum = sha256s["ARCH_TYPE_MACOS_AMD64"]
    if os == "windows":
        sum = sha256s["ARCH_TYPE_WINDOWS_AMD64"]
    if os == "macos" and cpu == "arm64":
        sum = sha256s["ARCH_TYPE_MACOS_ARM64"]

    ctx.report_progress("Downloading " + bin)

    download_info = ctx.download(
        url = "{}/download/endorlabs/v{}/binaries/{}".format(repository_url, version, bin),
        sha256 = sum,
        executable = True,
        output = output,
    )

    if os == "macos":
        os = "osx"

    ctx.file(
        "BUILD",
        _BUILD_FILE.format(
            os = os,
            cpu = cpu,
            rules_endorctl_repo_name = Label("//endorctl/repositories.bzl").workspace_name,
        ),
    )
    return update_attrs(ctx.attr, ["version"], {"version": version})

endorctl_download_releases = repository_rule(
    implementation = _endorctl_download_releases_impl,
    attrs = {
        "version": attr.string(
            doc = "Endorctl release version",
        ),
        "repository_url": attr.string(
            doc = "Repository url base used for downloads",
            default = "https://api.endorlabs.com",
        ),
    },
)

# buildifier: disable=unnamed-macro
def rules_endorctl_toolchains(name = _TOOLCHAINS_REPO, version = None, repository_url = None):
    """rules_endorctl_toolchains sets up toolchains for endorctl

    Args:
        name: The name of the toolchains repository. Defaults to "rules_endorctl_toolchains"
        version: Release version, eg: `1.6.35`. If `None` defaults to latest
        repository_url: The repository url base used for downloads. Defaults to "https://api.endorlabs.com"
    """

    endorctl_download_releases(name = name, version = version, repository_url = repository_url)
    _register_toolchains(name, "endorctl")

def _register_toolchains(repo, cmd):
    native.register_toolchains(
        "@{repo}//:{cmd}_toolchain".format(
            repo = repo,
            cmd = cmd,
        ),
    )
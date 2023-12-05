"""Defines endorctl_scan rule"""

_DOC = """
`endorctl_scan` is a test rule that run endorctl scan.
"""

_TOOLCHAIN = str(Label("//endorctl/tools/endorctl:toolchain_type"))

def _endorctl_scan(ctx):
    
    # TODO
    # Right now we need to run the rule like
    # bazel test --test_env=ENDOR_TOKEN --test_output=all --test_env=ENDOR_SCAN_PATH=$(pwd) --test_env=HOME --sandbox_writable_path=$HOME/.endorctl  //examples/java:endorctl-scan
    # Ideally the ENDOR_SCAN_PATH, HOME and the sandbox_writable_path should not be needed.

    cmd = "{} scan --use-bazel".format(ctx.toolchains[_TOOLCHAIN].cli.short_path)

    for target in ctx.attr.targets:
        cmd = "{} --bazel-include-targets={}".format(cmd, str(target.label)[1:])

    for args in ctx.attr.scan_args:
        cmd = "{} {}".format(cmd, args)

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
        is_executable = True,
    )

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(
                files = [ctx.toolchains[_TOOLCHAIN].cli],
            ),
        ),
    ]

endorctl_scan_test = rule(
    implementation = _endorctl_scan,
    doc = _DOC,
    attrs = {
        "targets": attr.label_list(
            mandatory = True,
            doc = "The targets to scan",
        ),
        "scan_args": attr.string_list(
            doc = "Additional args given to endorctl for the scan."
        ),
    },
    
    toolchains = [_TOOLCHAIN],
    test = True,
)

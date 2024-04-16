def get_params():
    result = []
    result += [f"alpha={str(param).replace('.', '_')}" for param in config["PARAMS"]["ALPHA"]]
    result += [
        f"{param1}={param2}"
        for param1 in config["PARAMS"]["MODE"] or [config["DEFAULT_PARAMS"]["MODE"]]
        for param2 in config["PARAMS"]["T_MAX"] or [config["DEFAULT_PARAMS"]["T_MAX"]]
    ]
    result += [f"hash={param}" for param in config["PARAMS"]["NUM_HASHES"]]
    result += [f"kmer={param}" for param in config["PARAMS"]["KMER_SIZE"]]
    result += [f"relaxed-fpr={str(param).replace('.', '_')}" for param in config["PARAMS"]["RELAXED_FPR"]]
    return result


rule store_timings:
    input:
        files=expand(
            f"{config['BUILD_DIR']}/{{param}}/out.time",
            param=get_params(),
        ),
    output:
        f"{config['BUILD_DIR']}/time",
    priority: 2
    log:
        "log/store_timings.log",
    conda:
        "../envs/r_basic_env.yaml"
    shell:
        """
        Rscript summarize_results.R "time_format" {input.files} &>> {log}
        """


rule store_sizes:
    input:
        files=expand(
            f"{config['BUILD_DIR']}/{{param}}/out.sizes",
            param=get_params(),
        ),
    output:
        f"{config['BUILD_DIR']}/size",
    priority: 2
    log:
        "log/store_sizes.log",
    conda:
        "../envs/r_basic_env.yaml"
    shell:
        """
        Rscript summarize_results.R "size_format" {input.files} &>> {log}
        """

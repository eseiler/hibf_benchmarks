rule raptor_layout:
    output:
        LAYOUT_FILE=f"{config['BUILD_DIR']}/{{key}}={{param}}/layout",
        LAYOUT_TIME=f"{config['BUILD_DIR']}/{{key}}={{param}}/layout.time",
    threads: config["NUM_THREADS"]
    priority: 2
    log:
        "log/raptor_layout_{key}_{param}.log",
    conda:
        "../envs/raptor_env.yaml"
    script:
        "raptor_layout.py",


rule raptor_build:
    input:
        LAYOUT_FILE=f"{config['BUILD_DIR']}/{{key}}={{param}}/layout",
    output:
        INDEX_FILE=f"{config['BUILD_DIR']}/{{key}}={{param}}/index",
        INDEX_TIME=f"{config['BUILD_DIR']}/{{key}}={{param}}/index.time",
    threads: config["NUM_THREADS"]
    priority: 1
    log:
        "log/raptor_build_{key}_{param}.log",
    conda:
        "../envs/raptor_env.yaml"
    params:
        RAPTOR_BINARY=config["RAPTOR_BINARY"],
        WINDOW_SIZE=config["DEFAULT_PARAMS"]["WINDOW_SIZE"],
    shell:
        """
    (echo "[$(date +"%Y-%m-%d %T")] Running raptor build for {wildcards.key}={wildcards.param}."
    {params.RAPTOR_BINARY} build \
      --input {input.LAYOUT_FILE} \
      --output {output.INDEX_FILE} \
      --window {params.WINDOW_SIZE} \
      --quiet \
      --timing-output {output.INDEX_TIME} \
      --threads {threads}
    ) &>> {log}
    """


rule raptor_search:
    input:
        INDEX_FILE=f"{config['BUILD_DIR']}/{{key}}={{param}}/index",
    output:
        RESULT_FILE=f"{config['BUILD_DIR']}/{{key}}={{param}}/out",
        RESULT_TIME=f"{config['BUILD_DIR']}/{{key}}={{param}}/out.time",
    threads: config["NUM_THREADS"]
    log:
        "log/raptor_search_{key}_{param}.log",
    conda:
        "../envs/raptor_env.yaml"
    params:
        RAPTOR_BINARY=config["RAPTOR_BINARY"],
        QUERY_FILE=config["QUERY_FILE"],
        QUERY_ERRORS=config["DATA_PARAMETERS"]["QUERY_ERRORS"],
    shell:
        """
    (echo "[$(date +"%Y-%m-%d %T")] Running raptor search for {wildcards.key}={wildcards.param}."
    {params.RAPTOR_BINARY} search \
      --index {input.INDEX_FILE} \
      --query {params.QUERY_FILE} \
      --output {output.RESULT_FILE} \
      --error {params.QUERY_ERRORS} \
      --quiet \
      --timing-output {output.RESULT_TIME} \
      --threads {threads}
    ) &>> {log}
    """


rule display_layout:
    input:
        LAYOUT_FILE=f"{config['BUILD_DIR']}/{{key}}={{param}}/layout",
    output:
        SIZE_FILE=f"{config['BUILD_DIR']}/{{key}}={{param}}/out.sizes",
    threads: config["NUM_THREADS"]
    log:
        "log/display_layout_{key}_{param}.log",
    conda:
        "../envs/raptor_env.yaml"
    params:
        DISPLAY_LAYOUT_BINARY=config["DISPLAY_LAYOUT_BINARY"],
        WINDOW_SIZE=config["DEFAULT_PARAMS"]["WINDOW_SIZE"],
    shell:
        """
    (echo "[$(date +"%Y-%m-%d %T")] Running display_layout for {wildcards.key}={wildcards.param}."
    {params.DISPLAY_LAYOUT_BINARY} sizes \
      --input {input.LAYOUT_FILE} \
      --output {output.SIZE_FILE} \
      --threads {threads}
    ) &>> {log}
    """

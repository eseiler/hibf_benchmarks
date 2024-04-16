
rule prepare_data_for_plot:
    input:
        SIZE_FILE=f"{config['BUILD_DIR']}/size",
        TIME_FILE=f"{config['BUILD_DIR']}/time",
    output:
        expand(
            f"{config['BUILD_DIR']}/prepared_{{format}}/{{key}}",
            format=["time", "size"],
            key=config["KEYS"],
        ),
    log:
        "log/prepare_data_for_plot.log",
    conda:
        "../envs/r_basic_env.yaml"
    script:
        "../extract_results.R"


rule plot_data:
    input:
        expand(
            f"{config['BUILD_DIR']}/prepared_{{format}}/{{key}}",
            format=["time", "size"],
            key=config["KEYS"],
        ),
    output:
        f"{config['PLOT_DIR']}/index.html",
    log:
        "log/plot_data.log",
    conda:
        "../envs/bokeh_env.yaml"
    script:
        "../bokeh_plot/plot.py"

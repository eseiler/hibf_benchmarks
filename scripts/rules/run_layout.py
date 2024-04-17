"""Runs raptor layout."""

from snakemake.shell import shell

kmer_size = (
    snakemake.wildcards.param if snakemake.wildcards.key == "kmer" else snakemake.config["DEFAULT_PARAMS"]["KMER_SIZE"]
)
mode = (
    snakemake.wildcards.key
    if snakemake.wildcards.key in ["U+R", "U", "none"]
    else snakemake.config["DEFAULT_PARAMS"]["MODE"]
)
t_max = (
    snakemake.wildcards.param
    if snakemake.wildcards.key in ["U+R", "U", "none"]
    else snakemake.config["DEFAULT_PARAMS"]["T_MAX"]
)
num_hash = (
    snakemake.wildcards.param if snakemake.wildcards.key == "hash" else snakemake.config["DEFAULT_PARAMS"]["NUM_HASHES"]
)
relaxed_fpr = (
    snakemake.wildcards.param.replace("_", ".")
    if snakemake.wildcards.key == "r-relaxed"
    else snakemake.config["DEFAULT_PARAMS"]["R_FPR"]
)
alpha = (
    snakemake.wildcards.param.replace("_", ".")
    if snakemake.wildcards.key == "alpha"
    else snakemake.config["DEFAULT_PARAMS"]["ALPHA"]
)
command = f"""{snakemake.config['RAPTOR_BINARY']} layout \
            --input {snakemake.config['FILENAMES_FILE']} \
            --output {snakemake.output.LAYOUT_FILE} \
            --kmer {kmer_size} \
            --window {snakemake.config["DEFAULT_PARAMS"]['WINDOW_SIZE']} \
            --tmax {t_max} \
            --fpr {snakemake.config["DEFAULT_PARAMS"]['M_FPR']} \
            --relaxed-fpr {relaxed_fpr} \
            --hash {num_hash} \
            --alpha {alpha} \
            --max-rearrangement-ratio 0.5 \
            --sketch-bits 12 \
            --timing-output {snakemake.output.LAYOUT_TIME} \
            --threads {snakemake.threads} &>> {snakemake.log}"""
shell(command)

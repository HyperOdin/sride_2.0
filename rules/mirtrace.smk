rule mir_trace:
    input:
        "reads/trimmed/{sample}-R1-trimmed.fq"
    output:
        "mir_trace/{sample}/mirtrace-results.json",
        "mir_trace/{sample}/mirtrace-stats-length.tsv",
        "mir_trace/{sample}/mirtrace-stats-contamination_basic.tsv",
        "mir_trace/{sample}/mirtrace-stats-mirna-complexity.tsv"
    conda:
        "../envs/mirtrace.yaml"
    params:
        outdir="mir_trace/{sample}",
        params="--force",
        species=config.get("rules").get("mir_trace").get("params")
    shell:
        "mirtrace "
        "qc "
        "{params.species} "
        "-o {params.outdir} "
        "{input} "
        "{params.params} "

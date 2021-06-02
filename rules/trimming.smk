
rule pre_rename_fastq_se:
    input:
        r1="reads/untrimmed/merged/{sample}-R1.fq.gz"
    output:
        r1="reads/untrimmed/{sample}.fq.gz"
    shell:
        "cp {input.r1} {output.r1}"


rule trim_galore_se:
    input:
        "reads/untrimmed/{sample}.fq.gz"
    output:
        "reads/trimmed/{sample}_trimmed.fq",
        "reads/trimmed/{sample}.fq.gz_trimming_report.txt"
    params:
        extra=config.get("rules").get("trim_galore_se").get("params")
    log:
        "logs/trim_galore/{sample}.log"
    benchmark:
        "benchmarks/trim_galore/{sample}.txt"
    wrapper:
        config.get("wrappers").get("trim_galore_se")

rule post_rename_fastq_se:
    input:
        r1="reads/trimmed/{sample}_trimmed.fq"
    output:
        r1="reads/trimmed/{sample}-R1-trimmed.fq"
    shell:
        "mv {input.r1} {output.r1}"


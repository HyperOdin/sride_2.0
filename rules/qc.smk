rule fastqc:
    input:
       "reads/untrimmed/{sample}.fq.gz"
    output:
        html="qc/fastqc/untrimmed_{sample}.html",
        zip="qc/fastqc/untrimmed_{sample}_fastqc.zip"
    log:
        "logs/fastqc/untrimmed/{sample}.log"
    params: ""
    wrapper:
        config.get("wrappers").get("fastqc")

rule fastqc_trimmed:
    input:
       "reads/trimmed/{sample}-R1-trimmed.fq"
    output:
        html="qc/fastqc/trimmed_{sample}.html",
        zip="qc/fastqc/trimmed_{sample}_fastqc.zip"
    log:
        "logs/fastqc/trimmed/{sample}.log"
    params: ""
    wrapper:
        config.get("wrappers").get("fastqc")

rule fastq_screen:
    input:
        "reads/trimmed/{sample}-R1-trimmed.fq.gz"
    output:
        png="qc/fastqscreen/trimmed_{sample}.fastq_screen.png",
        txt="qc/fastqscreen/trimmed_{sample}.fastq_screen.txt",
        html="qc/fastqscreen/trimmed_{sample}.fastq_screen.html"
    conda:
        "../envs/fastq_screen.yaml"
    params:
        fastq_screen_config=config.get("rules").get("fastq_screen").get("params"),
        subset=100000,
        aligner='bowtie2',
        prefix="{sample}" #lambda wildcards: wildcards.sample
    threads: pipeline_cpu_count()
    shell:
        "fastq_screen  "
        "--force "
        "--aligner {params.aligner} "
        "--conf {params.fastq_screen_config} "
        "--subset {params.subset} "
        "--threads {threads} "
        "{input[0]} "
        "&& find ./ -name {params.prefix}*_screen.txt -type f -print0 | xargs -0 -I file mv " \
        "file {output.txt} ;"
        "find ./ -name {params.prefix}*_screen.png -type f -print0 | xargs -0 -I file mv " \
        "file {output.png} ;"
        "find ./ -name {params.prefix}*_screen.html -type f -print0 | xargs -0 -I file mv " \
        "file {output.html} "

rule multiqc:
    input:
        expand("qc/fastqc/untrimmed_{sample.sample}_fastqc.zip", sample=samples.reset_index().itertuples()),
        expand("qc/fastqc/trimmed_{sample.sample}_fastqc.zip", sample=samples.reset_index().itertuples()),
        expand("reads/trimmed/{sample.sample}.fq.gz_trimming_report.txt", sample=samples.reset_index().itertuples()),
        #expand("qc/fastqscreen/trimmed_{sample.sample}.fastq_screen.txt", sample=samples.reset_index().itertuples()),
        #expand("qc/trimmed_{sample}.fastq_screen.txt", sample=config.get('samples')),
        expand("mir_trace/{sample.sample}/mirtrace-results.json", sample=samples.reset_index().itertuples()),
        expand("mir_trace/{sample.sample}/mirtrace-stats-length.tsv", sample=samples.reset_index().itertuples()),
        expand("mir_trace/{sample.sample}/mirtrace-stats-contamination_basic.tsv", sample=samples.reset_index().itertuples()),
        expand("mir_trace/{sample.sample}/mirtrace-stats-mirna-complexity.tsv", sample=samples.reset_index().itertuples())

    output:
        "qc/multiqc.html"
    params:
        params=config.get("rules").get("multiqc").get("arguments"),
        outdir="qc",
        outname="multiqc.html"
    conda:
        "../envs/multiqc.yaml"
    log:
        "logs/multiqc/multiqc.log"
    shell:
        "multiqc "
        "{input} "
        "{params.params} "
        "-o {params.outdir} "
        "-n {params.outname} "
        ">& {log}"

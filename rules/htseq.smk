rule bowtie_mapping:
    input:
        sample="reads/trimmed/{sample}-R1-trimmed.fq",
        index_ready="bowtie_index_ready",
        fa=resolve_single_filepath(*references_abs_path(ref='references'), config.get("genome_fasta"))
    output:
        bam="reads/aligned/{sample}.bam"
    params:
         params=config.get("rules").get("bowtie_mapping").get("params"),
         basename=config.get("rules").get("bowtie_mapping").get("basename")
    threads: pipeline_cpu_count()
    conda:
        "../envs/bowtie2.yaml"
    shell:
        "bowtie2 "
        "{params.params} "
        "{params.basename} "
        "{input.sample} "
        "| samtools view "
        "-bT "
        "{input.fa} - "
        "| samtools sort - "
        "-o {output.bam}"

rule index:
    input:
        "reads/aligned/{sample}.bam"
    output:
        "reads/aligned/{sample}.bam.bai"
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools index "
        "{input}"

rule htseq:
    input:
        bam="reads/aligned/{sample}.bam",
        bai="reads/aligned/{sample}.bam.bai",
        gff=config.get("htseq_gff")
    output:
        counts="htseq/{sample}.counts"
    conda:
        "../envs/htseq.yaml"
    shell:
        "htseq-count "
        "-f bam "
        "-r pos "
        "-t miRNA "
        "-i Name "
        "-q {input.bam} "
        "{input.gff} "
        ">{output.counts}"



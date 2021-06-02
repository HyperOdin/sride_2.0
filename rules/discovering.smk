rule bowtie_build_index:
    input:
        resolve_single_filepath(*references_abs_path(ref='references'), config.get("genome_fasta"))
    output:
        touch("bowtie_index_ready"),
        genome="{label}.fa".format(label=get_references_label(ref='references'))
    conda:
        "../envs/bowtie2.yaml"
    params:
        label=get_references_label(ref='references')
    threads: pipeline_cpu_count()
    log: "logs/bowtie/build_index.log"
    shell:
        "rsync -av {input} {output.genome} "
        "&& bowtie2-build "
        "--threads {threads} "
        "{output.genome} {params.label} "
        "&>{log} "


rule pirna_build_index:
    input:
        resolve_single_filepath(*references_abs_path(ref='pirna_reference'), config.get("pirna_fasta"))
    output:
        touch("pirna_index_ready"),
        genome="{label}.fa".format(label=get_references_label(ref='pirna_reference'))
    conda:
        "../envs/bowtie2.yaml"
    params:
        label=get_references_label(ref='pirna_reference')
    threads: pipeline_cpu_count()
    log: "logs/pirna/build_index.log"
    shell:
        "rsync -av {input} {output.genome} "
        "&& bowtie2-build "
        "--threads {threads} "
        "{output.genome} {params.label} "
        "&>{log} "


rule mirdeep2_alignment:
    input:
        "reads/trimmed/{sample}-R1-trimmed.fq",
        index_ready="bowtie_index_ready"
    output:
        fa=temp("discovering/{sample}_deepseq.fa"),
        arf=temp("discovering/{sample}_reads_vs_genome.arf")
    shadow: "shallow"
    conda:
        "../envs/mirdeep2.yaml"
    params:
        params=config.get("rules").get("mirdeep2_alignment").get("params"),
        label=get_references_label(ref='references')
    log:
        "logs/mirdeep2/{sample}_alignment.log"
    threads: pipeline_cpu_count()
    shell:
        "mapper.pl "
        "{input[0]} "
        "{params.params} "
        "-p {params.label} "
        "-s {output.fa} "
        "-t {output.arf} "
        "-o {threads} "
        "&> {log} "


rule pre_mirdeep2_identification:
    input:
        miRNAs_ref=config.get("mirna_ref"),
        miRNAs_other=config.get("mirna_other"),
        miRNAs_ref_precursors=config.get("mirna_ref_precursors")
    output:
        "miRNAs_ref",
        "miRNAs_other",
        "miRNAs_ref_precursors"
    shell:
        "cp {input[0]} {output[0]} "
        "&& cp {input[1]} {output[1]} "
        "&& cp {input[2]} {output[2]} "


rule mirdeep2_identification:
    input:
        fa="discovering/{sample}_deepseq.fa",
        arf="discovering/{sample}_reads_vs_genome.arf",
        genome=resolve_single_filepath(*references_abs_path(ref='references'), config.get("genome_fasta")),
        miRNAs_ref="miRNAs_ref",
        miRNAs_other="miRNAs_other",
        miRNAs_ref_precursors="miRNAs_ref_precursors"
    output:
        result_html="discovering/{sample}/{sample}_result.html",
        result_csv="discovering/{sample}/{sample}_result.csv",
        survey="discovering/{sample}/{sample}_survey.csv",
        mrd="discovering/{sample}/{sample}_output.mrd"
    shadow: "shallow"
    conda:
        "../envs/mirdeep2.yaml"
    params:
        params=config.get("rules").get("mirdeep2_identification").get("params"),
        prefix="{sample}" #lambda wildcards: wildcards.sample
    log:
        "logs/mirdeep2/{sample}_identification.log"
    shell:
        "miRDeep2.pl "
        "{input.fa} "
        "{input.genome} "
        "{input.arf} "
        "{input.miRNAs_ref} "
        "{input.miRNAs_other} "
        "{input.miRNAs_ref_precursors} "
        "-r {params.prefix} "
        "{params.params} "
        "&> {log} "
        "&& mkdir -p {params.prefix} && cp -r pdf* discovering/{params.prefix} "
        "&& find ./ -name survey.csv -type f -print0 | xargs -0 -I file mv " \
        "file {output.survey} "
        "&& find ./ -name output.mrd -type f -print0 | xargs -0 -I file mv " \
        "file {output.mrd} "
        "&& find ./ -name result*.html -type f -print0 | xargs -0 -I file mv " \
        "file {output.result_html} "
        "&& find ./ -name result*.csv -type f -print0 | xargs -0 -I file mv " \
        "file {output.result_csv} "


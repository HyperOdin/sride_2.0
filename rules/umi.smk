def get_fastq(wildcards,samples,read_pair='fq'):
    return samples.loc[wildcards.sample,
                     [read_pair]].dropna()[0]

rule UMI_tools:
    input:
#        lambda wildcards: get_fastq(wildcards, samples, read_pair="fq1")
        "reads/untrimmed/merged/{sample}-R1.fq.gz"
    output:
        "reads/umi_extract/{sample}_umi.fq.gz"
    conda:
        "../envs/umi_tools.yaml"
    log:
        "logs/umi_tools/{sample}_UMI_trimmed.log"
    shell:
        "umi_tools extract "
        "--stdin={input} "
        "--stdout={output} "
        "--log={log} "
        "--extract-method=regex "
        "--bc-pattern='.+(?P<discard_1>AACTGTAGGCACCATCAAT)"
        "{{s<=2}}"
        "(?P<umi_1>.{{12}})(?P<discard_2>.*)'"


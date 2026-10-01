# Initial setup
configfile: "config.yaml"

SAMPLE = config["sample"]
SRA_ACCESSION = config["sra_accession"]

SAMPLE_DIR = SAMPLE

RESULTS_DIR = f"{SAMPLE}/results"
DATA_DIR = f"{SAMPLE}/data/raw"

R1 = f"{DATA_DIR}/{SAMPLE}_R1.raw.fastq.gz"
R2 = f"{DATA_DIR}/{SAMPLE}_R2.raw.fastq.gz"

FASTQC_DIR = f"{RESULTS_DIR}/fastqc_raw"
FASTP_DIR = f"{RESULTS_DIR}/fastp_report"


# Final workflow targets
rule all:
    input:
        R1,
        R2,
        f"{FASTQC_DIR}/{SAMPLE}_R1.raw_fastqc.html",
        f"{FASTQC_DIR}/{SAMPLE}_R2.raw_fastqc.html",
        f"{FASTP_DIR}/{SAMPLE}_R1_trimmed.fastq.gz",
        f"{FASTP_DIR}/{SAMPLE}_R2_trimmed.fastq.gz"


# Download paired-end data from SRA
rule download_sra:
    output:
        r1=R1,
        r2=R2

    params:
        accession=SRA_ACCESSION,
        data_dir=DATA_DIR

    threads: 12

    conda:
        "envs/sra.yaml"

    shell:
        """
        prefetch {params.accession}

        fasterq-dump \
            {params.accession} \
            --split-files \
            --threads {threads} \
            --outdir {params.data_dir}

        mv {params.data_dir}/{params.accession}_1.fastq \
           {params.data_dir}/{SAMPLE}_R1.raw.fastq

        mv {params.data_dir}/{params.accession}_2.fastq \
           {params.data_dir}/{SAMPLE}_R2.raw.fastq

        pigz -p {threads} \
            {params.data_dir}/{SAMPLE}_R1.raw.fastq \
            {params.data_dir}/{SAMPLE}_R2.raw.fastq
        """    


#Fastqc on raw paired-end reads
rule fastqc_raw:
    input:
        r1=R1,
        r2=R2

    output:
        html_r1=f"{FASTQC_DIR}/{SAMPLE}_R1.raw_fastqc.html",
        zip_r1=f"{FASTQC_DIR}/{SAMPLE}_R1.raw_fastqc.zip",
        html_r2=f"{FASTQC_DIR}/{SAMPLE}_R2.raw_fastqc.html",
        zip_r2=f"{FASTQC_DIR}/{SAMPLE}_R2.raw_fastqc.zip"

    threads:4

    conda:
        "envs/qc.yaml"

    shell:
        """
        fastqc \
        --threads {threads} \
        --outdir {FASTQC_DIR} \
        {input.r1} \
        {input.r2}
        """
#Rule for fastp for adapter trimmiming and not perform other quality filtering
rule fastp_raw:
    input:
        r1=R1,
        r2=R2
    
    output:
        html=f"{FASTP_DIR}/{SAMPLE}_fastp_report.html",
        json=f"{FASTP_DIR}/{SAMPLE}_fastp_report.json",
        trimmed_r1=f"{FASTP_DIR}/{SAMPLE}_R1_trimmed.fastq.gz",
        trimmed_r2=f"{FASTP_DIR}/{SAMPLE}_R2_trimmed.fastq.gz"

    threads:4

    conda:"envs/qc.yaml"

    shell:
        """
        fastp \
            -i {input.r1} \
            -I {input.r2} \
            -o {output.trimmed_r1} \
            -O {output.trimmed_r2} \
            --detect_adapter_for_pe \
            --disable_quality_filtering \
            --thread {threads} \
            --json {output.json} \
            --html {output.html}
        """
        


 


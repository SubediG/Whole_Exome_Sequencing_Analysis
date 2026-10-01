<div align="center">

#Reproducible Whole Exome Sequencing Analysis With Snakemake and Conda Environment

### A reproducible Snakemake workflow for WES preprocessing and quality control

**SRR35940869 · Snakemake · Conda · FastQC · fastp · MultiQC**

</div>

---

## About

This project builds a **reproducible whole-exome sequencing workflow** using Snakemake and Conda.

The current pipeline downloads a public paired-end dataset which is huge ```bash(let it run and do your other stuffs)``` ,from NCBI SRA and performs:

```text
SRA download
    ↓
Raw FastQC
    ↓
fastp adapter trimming
    ↓
Trimmed FastQC
    ↓
MultiQC
```

The main goal is reproducibility: a user should be able to clone this repository, recreate the software environment, and run the same workflow without manually installing each bioinformatics tool.

---

## How To Reproduce The Workflow ?

### Prerequisites

You need:

- [Git](https://git-scm.com/)
- [Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)
- Internet access

FastQC, fastp, MultiQC, SRA Toolkit, and pigz are handled through the Conda environments defined in this repository.

### 1. Clone the repository

```bash
git clone https://github.com/SubediG/Whole_Exome_Sequencing_Analysis.git
cd Whole_Exome_Sequencing_Analysis
```

### 2. Recreate the Snakemake environment

```bash
conda env create -f environment.yml
conda activate wes-snakemake
```

### 3. Run the workflow

Dry run:

```bash
snakemake --use-conda --cores 12 -n -p
```

Run:

```bash
snakemake --use-conda --cores 12 -p
```

> Replace `12` with the number of CPU cores you want Snakemake to use if you have lesser or higher cores in your computer.

---

## Reproducibility approach

```text
GitHub repository
        ↓
environment.yml
        ↓
Snakemake
        ↓
Rule-specific Conda environments
        ↓
Same workflow + same analysis steps
```

- `environment.yml` provides the main Snakemake environment.
- `envs/sra.yaml` provides the SRA download tools.
- `envs/qc.yaml` provides the QC and trimming tools.
- `config.yaml` defines the sample and SRA accession.
- `Snakefile` defines the workflow and dependencies.

Large FASTQ files and generated results are not stored in GitHub; they are generated when the workflow runs.

---

## Current scope

The repository currently covers:

**SRA download → raw QC → adapter trimming → post-trimming QC → MultiQC**

Alignment, BAM processing, coverage analysis, and variant calling will be added as the workflow develops.

---

<div align="center">

**Gautam Subedi**

</div>


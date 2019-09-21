# DPnorm
Calculate the DPnorm values ([http://www.stgries.info/research/2010_STG_DispersionAdjFreq_CorpLingAppl.pdf]()) for a corpus.

## Usage

This script assumes that the corpus has been split into a corpus part per file prior to execution. When running the script, you then specify the directory where the [xml,txt] files for each corpus part is located, in addition to the filepath/filename of the output CSV that contains the resulting DPnorm scores for each token.

Example:
```bash
julia DPnorm.jl --input data/ --output scores.csv
```

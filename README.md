# DPnorm
Calculate the DPnorm values ([http://www.stgries.info/research/2010_STG_DispersionAdjFreq_CorpLingAppl.pdf]()) for a corpus.

## Usage

This script assumes that the corpus has been split into a corpus part per file prior to execution. When running the script, you then specify the directory where the [xml,txt] files for each corpus part is located, in addition to the filepath/filename of the output CSV that contains the resulting DPnorm scores for each token.

Example:
```bash
julia DPnorm.jl --input data/ --output scores.csv --punctuation !?.*-
```
### Input

The `input` flag should specify the directory where all of the xml/txt files for are located. Each of these files in the directory are assumed to be single corpus part.

### Output

The tool will write a CSV file with three columns (tokens, frequency, dpnorm) to a location specified by the `output` flag.

CSV column types:

| Column Name | Type    | Example | Description                                                  |
|-------------|---------|---------|--------------------------------------------------------------|
| token       | String  | ties    | The word/token from the corpus                               |
| frequency   | Integer | 20      | The total number of occurences of token in the corpus        |
| dpnorm      | Float   | 0.192   | The resulting DPnorm score for token within the range [0,1]. |

### Removing Punctuation

The tool includes an additional command line argument `punctuation` where you can supply a list of tokens (assumed to be a single character) to remove from the text before computing the scores.

#=
    Compute the DPNorm scores
=#
# Package setup
using Pkg
pkg"activate ."

# External imports
using CSV
using DataFrames
import StatsBase: countmap
using ProgressMeter
using LightXML
using ArgParse

# Internal imports
include("includes/stats.jl");
include("includes/data.jl");

# command line arguments
s = ArgParseSettings()
@add_arg_table s begin
    "--input", "-i"
        help = "input directory of corpus parts"
    "--output", "-o"
        help = "filename of the output CSV filename"
    "--punctuation", "-p"
        help = "strip function from text before computing scores. !!![DEFAULT: .,:;??!。，；：？！‚¿¡…'\"‘’`“”_|„()<=>[]{}‹›《》-–—一*]"
end
const ARGS = parse_args(s)

# setup the datapaths and count the number of corpus part
const CONV_DIR = ARGS["input"]
const OUTPUT_FN = ARGS["output"]
const punctuation = ARGS["punctuation"] == nothing ? split(".,:;??!。，；：？！‚¿¡…'\"‘’`“”_|„()<=>[]{}��‹›《》-–—一*", "") : split(ARGS["punctuation"], "")

english_dictionary = read_dictionary("includes/english-contractions-list.txt")
corpus_parts = read_dir(CONV_DIR)

# http://www.stgries.info/research/ToApp_STG_Dispersion_PHCL.pdf
n = length(corpus_parts)    # the length of the corpus in parts
s = [];

@info "Reading Corpus Parts from $CONV_DIR"

words_in_parts = []; @showprogress 1 "Reading Parts " for corpus_part in corpus_parts
    content = lowercase(read_corpus_part(joinpath(CONV_DIR, corpus_part)))
    content = strip_punctuation(content, punctuation, english_dictionary)
    content = content |> find_words
    push!(words_in_parts, content)
end

l = sum(length, words_in_parts)                 # the length of the corpus in words
s = [length(part)/l for part in words_in_parts] # the percentages of the n corpus part sizes
v = [countmap(part) for part in words_in_parts] # the frequences of a in each part
f = countmap(split(join([join(w, " ") for w in words_in_parts], " "), " "))  # the overall frequencies

norms = Dict{String,Float64}()
@showprogress 0.5 "Computing DPNorm Scores " for (word, total_freq) in f
    dp = 0
    for i in 1:n
        of = get(v[i], word, 0)
        dp += abs((of / total_freq) - s[i])
    end
    norms[word] = (0.5*dp) / (1 - minimum(s))
end

norms = sort(collect(norms), by=x->x[2])
@info "Writing DPNorm score to $OUTPUT_FN"
norms = DataFrame(token = [x[1] for x in norms],
                   frequency = [f[w[1]] for w in norms],
                   dpnorm = [x[2] for x in norms]);
CSV.write(OUTPUT_FN, norms)

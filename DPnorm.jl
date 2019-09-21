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

# Internal imports
include("includes/stats.jl");
include("includes/data.jl");

# setup the datapaths and count the number of corpus parts
const DATA_DIR = "data"
const CONV_DIR = joinpath(DATA_DIR, "test")
corpus_parts = read_dir(CONV_DIR)




# http://www.stgries.info/research/ToApp_STG_Dispersion_PHCL.pdf
n = length(corpus_parts)    # the length of the corpus in parts
s = [];

# get all the words per corpus
words_in_parts = [
    read_corpus_part(joinpath(CONV_DIR, corpus_part)) |> find_words
    for corpus_part in corpus_parts
]

l = sum(length, words_in_parts)                 # the length of the corpus in words
s = [length(part)/l for part in words_in_parts] # the percentages of the n corpus part sizes
v = [countmap(part) for part in words_in_parts] # the frequences of a in each part
f = countmap(split(join([join(w, " ") for w in words_in_parts], " "), " "))  # the overall frequencies

norms = Dict{String,Float64}()
for (word, total_freq) in f
    dp = 0
    for i in 1:n
        of = get(v[i], word, 0)
        dp += abs((of / total_freq) - s[i])
    end

    dp *= 0.5

    norms[word] = dp / (1 - minimum(s))
end

norms = sort(collect(norms), by=x->x[2])
@info "Writing DPNorm scores to"
norms = DataFrame(token = [x[1] for x in norms],
                   frequency = [f[w[1]] for w in norms],
                   dpnorm = [x[2] for x in norms]);
CSV.write("output.csv", norms)

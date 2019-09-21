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
N = length(corpus_parts)

# Compute the expected frequencies
ef = []; counts_per_part = []; total_counts = Dict{String,Int}();
@showprogress 1 "Computing Expected Frequencies..." for corpus_part in corpus_parts
    words = read_corpus_part(joinpath(CONV_DIR, corpus_part)) |> find_words
    freqs, counts = expected_frequency(words)

    push!(ef, freqs)
    push!(counts_per_part, counts)
    for (word, count) in counts
        total_counts[word] = get(total_counts, word, 0) + count
    end
end

# Compute the observed frequencies
of = [];
@showprogress 1 "Computing Observed Frequences..." for count in counts_per_part
    of_per_part = Dict{String,Float64}()
    for (w, v) in count
        of_per_part[w] = v / total_counts[w]
    end
    push!(of, of_per_part)
end

# Compute the DPnorm scores
scores = compute_dpnorm(ef, of, total_counts)
scores = sort(collect(scores), by=x->x[2])

# Write the output scores
@info "Writing DPNorm scores to"
scores = DataFrame(token = [x[1] for x in scores],
                   frequency = [total_counts[w[1]] for w in scores],
                   dpnorm = [x[2] for x in scores]);
CSV.write("output.csv", scores)

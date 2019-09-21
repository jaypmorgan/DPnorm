using Pkg
pkg"activate ."

using Base.Threads;
import StatsBase: countmap
using ProgressMeter
using Distributed
using DistributedArrays
using LightXML

include("includes/stats.jl");
include("includes/data.jl");

addprocs(4)
const DATA_DIR = "data"
const CONV_DIR = joinpath(DATA_DIR, "test")

corpus_parts = read_xml_dir(CONV_DIR)

N = length(corpus_parts)
ef = []; counts_per_part = []; total_counts = Dict{String,Int}(); @showprogress 1 "Computing Expected Frequencies..." for corpus_part in corpus_parts
    words = read_corpus_part(joinpath(CONV_DIR, corpus_part)) |> find_words
    freqs, counts = expected_frequency(words)

    push!(ef, freqs)
    push!(counts_per_part, counts)
    for (word, count) in counts
        total_counts[word] = get(total_counts, word, 0) + count
    end
end

of = []; @showprogress 1 "Computing Observed Frequences..." for count in counts_per_part
    of_per_part = Dict{String,Float64}()
    for (w, v) in count
        of_per_part[w] = v / total_counts[w]
    end
    push!(of, of_per_part)
end





compute_dpnorm(ef, of, total_counts)

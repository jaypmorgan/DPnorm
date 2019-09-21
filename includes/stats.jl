function find_words(conv::String)
    conv = split(conv, r"[\n\s]")  # split by new line or space
end

function expected_frequency(words)
    counts = countmap(words)
    exp_freq = values(counts) ./ length(words)
    exp_freq = Dict(keys(counts) .=> exp_freq)
    return exp_freq, counts
end

@inline function compute_dpnorm(ef, of, total_counts)
    all_words = keys(total_counts)
    norm = (1 - (1 / N))

    DP = Dict{String,Float64}();
    for word in all_words
        DP[word] = 0
    end

    @showprogress 5 "Computing DPnorms..." for word in all_words
        diffs = zeros(Float64,length(of)); for (i, (part_ef, part_of)) in enumerate(zip(ef, of))
            this_ef = get(part_ef, word, 0.)
            this_of = get(part_of, word, 0.)
            @inbounds diffs[i] = abs(this_of - this_ef)
        end
        @assert length(diffs) == length(of)
        DP[word] = (sum(diffs) / 2) / norm
    end
    return DP
end

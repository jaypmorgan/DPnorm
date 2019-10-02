"""
    read_dir(directory::String)

Read a directory of files, where each file is its own
corpus part.
"""
function read_dir(directory::String)
    readdir(directory)
end

"""
    read_dictionary(fn::String)
"""
function read_dictionary(fn::String)
    open(fn, "r") do f
        dictionary = split(read(f, String) |> strip |> String, ",")
        return dictionary
    end
end

"""
    strip_punctuation(s, p

Remove a list of punctuation terms from a string
"""
function strip_punctuation(str, p::AbstractArray, dictionary)
    split_string = split(str, " ")
    for pᵢ in p
        for (i, s) in enumerate(split_string)
            if s ∉ dictionary
                if pᵢ == "'"
                    s = replace(s, pᵢ => "")
                else
                    s = replace(s, pᵢ => " ")
                end
                split_string[i] = s
            end
        end
    end
    return replace(join(split_string, " "), "http " => "http://")
end

"""
    read_corpus_part(fn::String)

Read a corpus part from a text file and return the
contents as a string.
"""
function read_corpus_part(fn::String)
    if endswith(fn, ".txt")
        content = read_text_file(fn)
    elseif endswith(fn, ".xml")
        content = read_xml_file(fn)
    else
        @warn "Skipping $fn as there is no known method of reading it"
        content = ""
    end
    return replace_contents(content)
end

function read_text_file(fn::String)
    open(fn, "r") do f
        content = read(f, String) |> strip |> String
    end
end

"""
    read_xml_file(fn::String, corpus_part_tag)

Read a corpus part from an XML file where the "contents" or wording
to be read exists in a corpus_part_tag tag within the XML file.
"""
function read_xml_file(fn::String)
    xdoc = parse_file(fn)
    c = root(xdoc) |> content |> strip |> String
end


function replace_contents(c)
    # fix tokenisation from CQPweb if it has occured
    c = replace(c, "\n" => " ")
    c = replace(c, r"\sn't" => "n't")
    c = replace(c, r"\s'm" => "'m")
    c = replace(c, r"\s've" => "'ve")
    c = replace(c, r"\s'd" => "'d")
    c = replace(c, r"\s's" => "'s")
    c = replace(c, r"s\'t" => "'t")
    c = replace(c , r"\s'l" => "'l")
    c = replace(c, r"smiley" => "smile")
    c = replace(c, r"wan na" => "wanna")
    c = replace(c, r"gon na" => "gonna")
end

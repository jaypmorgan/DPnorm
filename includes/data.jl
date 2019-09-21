"""
    read_dir(directory::String)

Read a directory of files, where each file is its own
corpus part.
"""
function read_dir(directory::String)
    readdir(directory)
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
    return content
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
    c = replace(c, "\n" => "")
end

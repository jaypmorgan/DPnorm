function read_corpus_part(fn::String)
    open(fn, "r") do f
        content = read(f, String) |> strip |> String
    end
end

function read_xml_dir(fn::String; corpus_part_tag="conversation")
    parts_in_all_files = []
    for file in readdir(fn)
        parts_in_file = read_xml_file(joinpath(fn, file), corpus_part_tag)
        parts_in_all_files = union(parts_in_all_files, parts_in_file)
    end
    return parts_in_all_files
end

function read_xml_file(fn::String, corpus_part_tag)
    xdoc = parse_file(fn)
    xroot = root(xdoc)

    parts = []

    for part in get_elements_by_tagname(xroot, corpus_part_tag)
        messages_in_part = []
        for message in get_elements_by_tagname(part, "message")
            push!(messages_in_part, find_element(message, "text") |> content)
        end
        push!(parts, join(messages_in_part, " "))
    end
    return parts
end

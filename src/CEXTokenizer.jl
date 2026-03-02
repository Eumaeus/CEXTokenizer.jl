module CEXTokenizer

using CiteEXchange
using CitableBase   # for FileReader

export tokenize
export tokenize_text
export urn_for_token

"""
    tokenize(cexFile::AbstractString, outputFile::AbstractString; delimiter::AbstractString="#")

Process a CEX file, find all `#!ctsdata` blocks, tokenize each passage into
words / single punctuation marks / whitespace runs, and write one token per line
in the new tokenized CEX format to `outputFile`.

The output URN for each token follows exactly your spec:
- `.tokens` exemplar added after the version element
- token index appended as an extra field to the citation (passage) part
"""
function tokenize(cexFile::AbstractString, outputFile::AbstractString; delimiter::AbstractString = "#")
    blocklist = blocks(cexFile, FileReader)

    open(outputFile, "w") do io
        for blk in blocklist
            if blk.label == "ctsdata"
                for line in blk.lines
                    if occursin(delimiter, line)
                        parts = split(line, delimiter, limit = 2)
                        urn_str = strip(parts[1])
                        passage_text = parts[2]          # do NOT strip — we want all whitespace

                        tokens = tokenize_text(passage_text)

                        for (i, tok) in enumerate(tokens)
                            new_urn = urn_for_token(urn_str, i)
                            println(io, new_urn, delimiter, tok)
                        end
                    end
                end
            end
        end
    end
    nothing
end

# ------------------------------------------------------------------
# Helpers (public if you want; easy to extend/test)
# ------------------------------------------------------------------

"""
    tokenize_text(s::AbstractString) -> Vector{String}

Split a passage into tokens: words (\\p{L}\\p{N}+), single punctuation (\\p{P}),
or whitespace runs (\\s+). Preserves the exact sequence and content of your example.
"""
function tokenize_text(s::AbstractString)::Vector{String}
    tokens = String[]
    for m in eachmatch(r"([\p{L}\p{N}]+|[\p{P}]|\s+)", s)
        push!(tokens, m.match)
    end
    return tokens
end

"""
    urn_for_token(original_urn::AbstractString, token_index::Int) -> String

Returns a new CTS URN with `.tokens` inserted as the exemplar after the version
and the token index appended to the citation part (exactly as specified).
Works for the common form `urn:cts:namespace:work.version:passage`.
"""
function urn_for_token(original_urn::AbstractString, token_index::Int)::String
    startswith(original_urn, "urn:cts:") || error("Not a valid CTS URN: $original_urn")

    without_prefix = original_urn[9:end]  # after "urn:cts:"
    parts = split(without_prefix, ":", limit=3)
    length(parts) == 3 || error("Malformed CTS URN: $original_urn")

    namespace, workpart, passagepart = parts
    workparts = split(workpart, '.')

    # Add .tokens as the exemplar (after whatever version element exists)
    new_workparts = vcat(workparts, "tokens")
    new_work = join(new_workparts, '.')

    new_passage = passagepart * "." * string(token_index)

    return "urn:cts:" * namespace * ":" * new_work * ":" * new_passage
end

end # module
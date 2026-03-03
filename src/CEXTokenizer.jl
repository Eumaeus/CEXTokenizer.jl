module CEXTokenizer

using CiteEXchange
using CitableBase   # for FileReader
using BetaReader

export tokenize
export analytical_tokenize
export tokenize_text
export urn_for_token
export is_word_token
export to_analytical_beta

# ==================================================================
# Public API
# ==================================================================

"""
    tokenize(cexFile::AbstractString, outputFile::AbstractString; delimiter::AbstractString="#")

Tokenize every `#!ctsdata` passage:
- Words (optionally ending with `'` or `ʼ`) stay together as one token
- Other single punctuation marks and whitespace runs are separate tokens
- Output: one CEX line per token with `.tokens` exemplar
"""
function tokenize(cexFile::AbstractString, outputFile::AbstractString; delimiter::AbstractString = "#")
    _process_ctsdata(cexFile, outputFile, delimiter) do urn_str, passage_text, io
        tokens = tokenize_text(passage_text)
        for (i, tok) in enumerate(tokens)
            new_urn = urn_for_token(urn_str, i; exemplar = "tokens")
            println(io, new_urn, delimiter, tok)
        end
    end
end

"""
    analytical_tokenize(cexFile::AbstractString, outputFile::AbstractString; delimiter::AbstractString="#")

Identical parsing to `tokenize()`, but:
- Only **word tokens** (now including trailing `'` or `ʼ`) are emitted
- URNs use `.analytical_tokens` as the exemplar
- Each word (with its trailing apostrophe if present) is converted via `BetaReader.unicodeToBeta`, lower-cased, graves (`\\`) → acutes (`/`)
- Token indices **exactly match** the positions from `tokenize()`

Designed for Ancient Greek analytical pipelines.
"""
function analytical_tokenize(cexFile::AbstractString, outputFile::AbstractString; delimiter::AbstractString = "#")
    _process_ctsdata(cexFile, outputFile, delimiter) do urn_str, passage_text, io
        tokens = tokenize_text(passage_text)
        for (i, tok) in enumerate(tokens)
            if is_word_token(tok)
                analytical_tok = to_analytical_beta(tok)
                new_urn = urn_for_token(urn_str, i; exemplar = "analytical_tokens")
                println(io, new_urn, delimiter, analytical_tok)
            end
        end
    end
end

# ==================================================================
# Internal helpers (reused + new)
# ==================================================================

function _process_ctsdata(f::Function, cexFile::AbstractString, outputFile::AbstractString, delimiter::AbstractString)
    blocklist = blocks(cexFile, FileReader)
    open(outputFile, "w") do io
        for blk in blocklist
            if blk.label == "ctsdata"
                for line in blk.lines
                    if occursin(delimiter, line)
                        parts = split(line, delimiter, limit = 2)
                        urn_str = strip(parts[1])
                        passage_text = parts[2]   # preserve all whitespace
                        f(urn_str, passage_text, io)
                    end
                end
            end
        end
    end
    nothing
end

"""
    tokenize_text(s::AbstractString) -> Vector{String}

Now correctly glues a trailing apostrophe (`'` or `ʼ`) to the preceding word.
"""
function tokenize_text(s::AbstractString)::Vector{String}
    tokens = String[]
    for m in eachmatch(r"([\p{L}\p{N}]+['ʼ]?|['ʼ]|\p{P}|\s+)", s)
        push!(tokens, m.match)
    end
    tokens
end

# Analytical helpers
is_word_token(s::AbstractString)::Bool = occursin(r"^[\p{L}\p{N}]+['ʼ]?$", s)

"""
    urn_for_token(original_urn::AbstractString, token_index::Int; exemplar::AbstractString="tokens") -> String
"""
function urn_for_token(original_urn::AbstractString, token_index::Int; exemplar::AbstractString = "tokens")::String
    startswith(original_urn, "urn:cts:") || error("Not a valid CTS URN: $original_urn")
    without_prefix = original_urn[9:end]
    parts = split(without_prefix, ":", limit=3)
    length(parts) == 3 || error("Malformed CTS URN: $original_urn")

    namespace, workpart, passagepart = parts
    workparts = split(workpart, '.')

    new_workparts = vcat(workparts, exemplar)
    new_work = join(new_workparts, '.')

    new_passage = passagepart * "." * string(token_index)

    "urn:cts:" * namespace * ":" * new_work * ":" * new_passage
end

function to_analytical_beta(s::AbstractString)::String
    beta = BetaReader.unicodeToBeta(s)
    beta_lower = lowercase(beta)
    replace(beta_lower, '\\' => '/')
end

end # module
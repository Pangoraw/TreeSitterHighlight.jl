module TreeSitterHighlight

include("./libtree_sitter_highlight.jl")

import .LibTreeSitterHighlight as LTSH

function maybe_throw_ts_error(maybe_err)
    err(name) = error("Got error of type $name")

    if maybe_err == LibTreeSitterHighlight.TSHighlightOk
        # pass
    elseif maybe_err == LibTreeSitterHighlight.TSHighlightUnknownScope
        err("TSHighlightError::TSHighlightUnknownScope")
    elseif maybe_err == LibTreeSitterHighlight.TSHighlightTimeout
        err("TSHighlightError::TSHighlightTimeout")
    elseif maybe_err == LibTreeSitterHighlight.TSHighlightInvalidLanguage
        err("TSHighlightError::TSHighlightInvalidLanguage")
    elseif maybe_err == LibTreeSitterHighlight.TSHighlightInvalidUtf8
        err("TSHighlightError::TSHighlightInvalidUtf8")
    elseif maybe_err == LibTreeSitterHighlight.TSHighlightInvalidRegex
        err("TSHighlightError::TSHighlightInvalidRegex")
    elseif maybe_err == LibTreeSitterHighlight.TSHighlightInvalidQuery
        err("TSHighlightError::TSHighlightInvalidQuery")
    end
end

macro tscall(call)
    quote
        local res = $(esc(call))
        maybe_throw_ts_error(res)
    end
end

struct Language
    name::Symbol
    language::Ptr{Nothing}
end

mutable struct Highlighter
    # Keep these strings around
    names::Vector{String}
    attributes::Vector{String}

    ptr::Ptr{LTSH.TSHighlighter}
    languages::Vector{Language}

    function Highlighter(names, attributes, ptr)
        finalizer(LTSH.ts_highlighter_delete, new(names, attributes, ptr, Language[]))
    end
end

"""
    HighlightBuffer(names_attributes::Dict{String,String})

An HighlightBuffer is the object needed to perform syntax highlighting. The names
parameter represent the capture groups that should be wrapped in spans. The attributes
element corresponds to the corresponding HTML attributes that should be inserted in
the span of each of this spans.

```julia
julia> highlighter = Highlighter(Dict(
           "keyword" => "class=keyword",
       ))
Highlighter(Language[])
```
"""
function Highlighter(names_attributes::Dict{String,String})
    names = collect(keys(names_attributes))
    attributes = collect(values(names_attributes))
    Highlighter(names, attributes)
end

function Highlighter(names, attributes)
    @assert length(names) == length(attributes) "There should be an attribute for each name (got $(length(names)) names and $(length(attributes))) attributes)."
    res = LTSH.ts_highlighter_new(names, attributes, length(names))
    if res == C_NULL
        error("Failed to create an Highlighter")
    end
    Highlighter(names, attributes, res)
end

function Base.show(io::IO, highlighter::Highlighter)
    write(io, "Highlighter(")
    show(io, highlighter.languages)
    write(io, ")")
end

Base.unsafe_convert(::Type{Ptr{LTSH.TSHighlighter}}, highlighter::Highlighter) =
    highlighter.ptr

"""
    add_language!(
        highlighter::Highlighter,
        language::Language;
        scope::String,
        highlights_query::Union{Nothing,String}=nothing,
        injections_query::Union{Nothing,String}=nothing,
        locals_query::Union{Nothing,String} = nothing,
        injection_regex::String = string("^", language.name),
    )

Adds a language definition to the given highlighter.
"""
function add_language!(
    highlighter::Highlighter,
    language::Language;
    scope::String,
    highlights_query::Union{Nothing,String} = nothing,
    injections_query::Union{Nothing,String} = nothing,
    locals_query::Union{Nothing,String} = nothing,
    injection_regex::String = string("^", language.name),
)
    push!(highlighter.languages, language)
    # lang = Ref{TSLanguage}(language.language)

    @tscall LTSH.ts_highlighter_add_language(
        highlighter,
        scope,
        injection_regex,
        language.language,
        something(highlights_query, C_NULL),
        something(injections_query, C_NULL),
        something(locals_query, C_NULL),
        highlights_query === nothing ? 0 : length(highlights_query),
        injections_query === nothing ? 0 : length(injections_query),
        locals_query === nothing ? 0 : length(locals_query),
    )

    highlighter
end

mutable struct HighlightBuffer
    ptr::Ptr{LTSH.TSHighlightBuffer}

    function HighlightBuffer(ptr)
        finalizer(LTSH.ts_highlight_buffer_delete, new(ptr))
    end
end
function HighlightBuffer()
    res = LTSH.ts_highlight_buffer_new()
    if res == C_NULL
        error("Could not create HighlightBuffer")
    end
    HighlightBuffer(res)
end

Base.unsafe_convert(::Type{Ptr{LTSH.TSHighlightBuffer}}, buffer::HighlightBuffer) =
    buffer.ptr
function Base.convert(::Type{String}, buffer::HighlightBuffer)
    ptr = convert(Ptr{Cchar}, LTSH.ts_highlight_buffer_content(buffer))
    len = LTSH.ts_highlight_buffer_len(buffer)
    unsafe_string(ptr, len)
end

"""
    highlight(highlighter::Highlighter, source_code::String; scope::String)::String

Highlights the given source code in scope and returns an HTML string.
"""
function highlight(highlighter, source_code; scope)
    buffer = HighlightBuffer()
    @tscall LTSH.ts_highlighter_highlight(
        highlighter,
        scope,
        source_code,
        length(source_code),
        buffer,
        C_NULL,
    )

    # output_line_count = LTSH.ts_highlight_buffer_line_count(buffer)
    # output_line_offsets = LTSH.ts_highlight_buffer_line_offsets(buffer)
    # output_line_offsets = Base.unsafe_wrap(Array{Cuint}, output_line_offsets, output_line_count)

    # TODO: look into string indexing
    # lines = [
    #      output_string[start:end_]
    #      for (start, end_) in zip(output_line_offsets[begin:end-1], output_line_offsets[begin+1:end])
    # ]

    # for (i, line) in enumerate(lines)
    #     println("line $i #", line)
    # end

    convert(String, buffer)
end

export add_language!, Highlighter, highlight, Language

end # module

module LibTreeSitterHighlight

using tree_sitter_highlight_jll: libtree_sitter_highlight
using CEnum: @cenum

@cenum TSHighlightError begin
    TSHighlightOk
    TSHighlightUnknownScope
    TSHighlightTimeout
    TSHighlightInvalidLanguage
    TSHighlightInvalidUtf8
    TSHighlightInvalidRegex
    TSHighlightInvalidQuery
end

struct TSHighlighter end
struct TSHighlightBuffer end
struct TSLanguage end

# TSHighlighter *ts_highlighter_new(
#   const char **highlight_names,
#   const char **attribute_strings,
#   uint32_t highlight_count
# );
function ts_highlighter_new(highlight_names, attribute_strings, highlight_count)
    @ccall libtree_sitter_highlight.ts_highlighter_new(
        highlight_names::Ptr{Ptr{Cchar}},
        attribute_strings::Ptr{Ptr{Cchar}},
        highlight_count::Cuint,
    )::Ptr{TSHighlighter}
end

# // Delete a syntax highlighter.
# void ts_highlighter_delete(TSHighlighter *);
function ts_highlighter_delete(highlighter)
    @ccall libtree_sitter_highlight.ts_highlighter_delete(
        highlighter::Ptr{TSHighlighter},
    )::Cvoid
end

# // Add a `TSLanguage` to a highlighter. The language is associated with a
# // scope name, which can be used later to select a language for syntax
# // highlighting. Along with the language, you must provide a JSON string
# // containing the compiled PropertySheet to use for syntax highlighting
# // with that language. You can also optionally provide an 'injection regex',
# // which is used to detect when this language has been embedded in a document
# // written in a different language.
# TSHighlightError ts_highlighter_add_language(
#   TSHighlighter *self,
#   const char *scope_name,
#   const char *injection_regex,
#   const TSLanguage *language,
#   const char *highlight_query,
#   const char *injection_query,
#   const char *locals_query,
#   uint32_t highlight_query_len,
#   uint32_t injection_query_len,
#   uint32_t locals_query_len
# );
function ts_highlighter_add_language(
    self,
    scope_name,
    injection_regex,
    language,
    highlight_query,
    injection_query,
    locals_query,
    highlight_query_len,
    injection_query_len,
    locals_query_len,
)
    @ccall libtree_sitter_highlight.ts_highlighter_add_language(
        self::Ptr{TSHighlighter},
        scope_name::Cstring,
        injection_regex::Cstring,
        language::Ptr{TSLanguage},
        highlight_query::Cstring,
        injection_query::Cstring,
        locals_query::Cstring,
        highlight_query_len::Cuint,
        injection_query_len::Cuint,
        locals_query_len::Cuint,
    )::TSHighlightError
end

# // Compute syntax highlighting for a given document. You must first
# // create a `TSHighlightBuffer` to hold the output.
# TSHighlightError ts_highlighter_highlight(
#   const TSHighlighter *self,
#   const char *scope_name,
#   const char *source_code,
#   uint32_t source_code_len,
#   TSHighlightBuffer *output,
#   const size_t *cancellation_flag
# );
function ts_highlighter_highlight(
    self,
    scope_name,
    source_code,
    source_code_len,
    output,
    cancellation_flag,
)
    @ccall libtree_sitter_highlight.ts_highlighter_highlight(
        self::Ptr{TSHighlighter},
        scope_name::Cstring,
        source_code::Cstring,
        source_code_len::Cuint,
        output::Ptr{TSHighlightBuffer},
        cancellation_flag::Ptr{Csize_t},
    )::TSHighlightError
end


# // TSHighlightBuffer: This struct stores the HTML output of syntax
# // highlighting. It can be reused for multiple highlighting calls.
# TSHighlightBuffer *ts_highlight_buffer_new();
function ts_highlight_buffer_new()
    @ccall libtree_sitter_highlight.ts_highlight_buffer_new()::Ptr{TSHighlightBuffer}
end


# // Delete a highlight buffer.
# void ts_highlight_buffer_delete(TSHighlightBuffer *);
function ts_highlight_buffer_delete(highlighter)
    @ccall libtree_sitter_highlight.ts_highlight_buffer_delete(
        highlighter::Ptr{TSHighlightBuffer},
    )::Cvoid
end


# // Access the HTML content of a highlight buffer.
# const uint8_t *ts_highlight_buffer_content(const TSHighlightBuffer *);
function ts_highlight_buffer_content(highlighter)
    @ccall libtree_sitter_highlight.ts_highlight_buffer_content(
        highlighter::Ptr{TSHighlightBuffer},
    )::Ptr{Cuint}
end

# const uint32_t *ts_highlight_buffer_line_offsets(const TSHighlightBuffer *);
function ts_highlight_buffer_line_offsets(highlight_buffer)
    @ccall libtree_sitter_highlight.ts_highlight_buffer_line_offsets(
        highlight_buffer::Ptr{TSHighlightBuffer},
    )::Ptr{Cuint}
end

# uint32_t ts_highlight_buffer_len(const TSHighlightBuffer *);
function ts_highlight_buffer_len(highlight_buffer)
    @ccall libtree_sitter_highlight.ts_highlight_buffer_len(
        highlight_buffer::Ptr{TSHighlightBuffer},
    )::Cuint
end

# uint32_t ts_highlight_buffer_line_count(const TSHighlightBuffer *);
function ts_highlight_buffer_line_count(highlight_buffer)
    @ccall libtree_sitter_highlight.ts_highlight_buffer_line_count(
        highlight_buffer::Ptr{TSHighlightBuffer},
    )::Cuint
end

end # module LibTreeSitter

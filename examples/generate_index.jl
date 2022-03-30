using TreeSitterHighlight
using Markdown

const treesitter_javascript =
    "~/Projects/tree-sitter-javascript/build_so/libtreesitter_javascript.so" |> expanduser

const treesitter_julia =
    "~/Projects/tree-sitter-julia/build_so/libtreesitter_julia.so" |> expanduser

captures = [
    "symbol",
    "include",
    "variable",
    "comment",
    "tag",
    "function",
    "string",
    "keyword",
    "punctuation",
]

highlighter = Highlighter(Dict(capture => "class=$capture" for capture in captures))

js_scope = "source.js"
js_injection_regex = "^javascript"

js = Language(
    :javascript,
    @ccall treesitter_javascript.tree_sitter_javascript()::Ptr{Nothing}
)

js_highlights_query = read("./queries/javascript/highlights.scm", String)
js_injections_query = read("./queries/javascript/injections.scm", String)
js_locals_query = read("./queries/javascript/locals.scm", String)

add_language!(
    highlighter,
    js;
    scope = js_scope,
    injection_regex = js_injection_regex,
    highlights_query = js_highlights_query,
    injections_query = js_injections_query,
    locals_query = js_locals_query,
)

jl_scope = "source.jl"
jl_injection_regex = "^julia"

jl = Language(:julia, @ccall treesitter_julia.tree_sitter_julia()::Ptr{Nothing})

jl_highlights_query = read("./queries/julia/highlights.scm", String)
jl_injection_query = read("./queries/julia/injections.scm", String)
jl_locals_query = read("./queries/julia/locals.scm", String)

add_language!(
    highlighter,
    jl;
    scope = jl_scope,
    injection_regex = jl_injection_regex,
    highlights_query = jl_highlights_query,
    injections_query = jl_injection_query,
    locals_query = jl_locals_query,
)

scopes = Dict{String,String}("javascript" => js_scope, "julia" => jl_scope)

function Markdown.html(io::IO, code::Markdown.Code)
    if code.language ∈ ("julia", "javascript")
        write(io, "<pre>")
        write(io, highlight(highlighter, code.code; scope = scopes[code.language]))
        write(io, "</pre>")
    else
        write(io, code.code)
    end
end

readme = read("./README.md", String) |> Markdown.parse

generate_index() =
    open("index.html", "w") do f
        write(
            f,
            """
   <html>
   <head>
   <style>
   body {
       margin: 0;
       padding: 0;
       font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif;
   }

   h1, h2, h3, p {
       margin: 0;
       padding-top: 5px;
       padding-left: 20px;
       padding-right: 20px;
   }

   pre {
       padding: 20px;
       background: hsla(46, 90%, 98%, 1);
       color: #41323f;
   }

   pre p {
       white-space: pre-wrap;
       margin: 0;
   }

   .symbol, .symbol * {
       color: #815ba4 !important;
   }

   .comment {
       color: #e96ba8;
   }

   .keyword, .include {
       color: #ef6155;
   }

   .string {
       color: #da5616;
   }

   .function, .function * {
       color: #cc80ac !important;
   }

   .number {
       color: #815ba4;
   }

   .punctuation {
       color: #41323f;
   }

   .variable {
       color: #5668a4;
   }
   </style>
   </head>
   <body>
   """,
        )

        show(f, MIME"text/html"(), readme)

        write(
            f,
            """
   </body>
   </html>
   """,
        )
    end

generate_index()

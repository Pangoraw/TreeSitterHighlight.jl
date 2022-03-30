# TreeSitterHighlight.jl

> [🌠 View this readme rendered using TreeSitterHighlight.jl!](https://htmlview.glitch.me/?https://gist.github.com/Pangoraw/9ffaff45a2a0165dc9f10a6fdc116660)

A Julia package to export static HTML for highlighted code based on [`tree-sitter/highlight`](https://github.com/tree-sitter/tree-sitter/tree/master/highlight).

## Usage

To highlight a source file, you will need:

 - A Tree-sitter language.
 - Highlights queries that return category for matches.
 - Injections queries that specify when the language should switch.

```julia
using TreeSitterHighlight, tree_sitter_javascript_jll

highlighter = Highlighter(Dict(
    "keyword" => "class=keyword",
))

libts_js = tree_sitter_javascript_jll.libtreesitter_javascript_path

language = Language(
    :javascript,
    @ccall libts_js.tree_sitter_javascript()::Ptr{Nothing}
)

scope = "source.js"

add_language!(
    highlighter,
    language;
    scope,
    injection_regex,
    highlights_query,
    injections_query,
    locals_query,
)

function highlight_js_code(code::String)::String
    TreeSitterHighlight.highlight(highlighter, code; scope)
end

highlight_js_code("""
function main(msg) {
    console.log(msg)
}
""")
```

## Gallery

This readme is using a [Pluto](https://github.com/JuliaPluto/Pluto.jl) inspired theme and all the code highlighting is made using TreeSitterHighlight.jl!

### Javascript

```javascript
/**
 * Prints an hello world message to the console
 **/
function main() {
    let world = "world"
    const message = `Hello, ${world} !`;
    console.log(message);
}

main();
```

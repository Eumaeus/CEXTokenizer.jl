# CEXTokenizer

Tokenizes CEX `ctsdata` passages into word / punctuation / whitespace tokens while preserving canonical CTS URN citation.

## Usage

```julia
using CEXTokenizer
tokenize("homer.cex", "homer_tokens.cex")
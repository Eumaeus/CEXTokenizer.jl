# Grok Queries

## Setup

### Initial Query

I have a local directory named `CEXTokenizer.jl`. Inside this directory I would like to initialize a Julia project that will contain several public functions.

First, `CEXTokenizer.tokenize(cexFile, outputFile)` 

This should accept a path to a file in CEX format and a path for output. There is a Jula library for working with CEX files here: <https://github.com/cite-architecture/CiteEXchange.jl>. There is also a library for working with a "Citable Corpus" here: <https://github.com/cite-architecture/CitableCorpus.jl>

The function should find all passages of text, identified in blocks beginning  with the line `#!ctsdata`, followed by lines of citable textual data. 

One of these might look like this: `urn:cts:greekLit:tlg0012.tlg001.perseus_grc2:1.1#Μῆνιν ἄειδε θεὰ Πηληϊάδεω Ἀχιλῆος
` with a CtsUrn citation, followed by a delimiter (`#` by default), followed by a passage of text.

The function should tokenize the passage of text as follows: Each token should be a word, or a punctuation mark, or white-space.

The output should be a text-file consisting of one line for each token. Each line should follow the CEX format of `CtsUrn+dellimiter+text`. The text should be one token (word, punctuation, or white-space). The URN should be:

- The original URN, but with `.tokens` added as an "examplar-ID" after the version-element, and an additional period-delimited field added to the citation-element. That additional citation-field should be an enumeration of the token based on its sequence in the original passage of text.

- So, if the input-line is `urn:cts:greekLit:tlg0012.tlg001.perseus_grc2:1.1#Μῆνιν ἄειδε θεὰ Πηληϊάδεω Ἀχιλῆος`, then the first three output-lines should be:

	urn:cts:greekLit:tlg0012.tlg001.perseus_grc2.tokens:1.1.1#Μῆνιν
	urn:cts:greekLit:tlg0012.tlg001.perseus_grc2.tokens:1.1.2# 
	urn:cts:greekLit:tlg0012.tlg001.perseus_grc2.tokens:1.1.3#ἄειδε

If this makes sense, could you help me build the skeleton for this Julia project, with provision for adding some unit-tests, addition additional functions, and ultimately committing it to GitHub?

### Follow-up

Thanks for all this! As generated, my `Project.toml` looks like this:

```
[deps]
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CiteEXchange = "e2e9ead3-1b6c-4e96-b95f-43e6ab899178"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
```

And trying to run tests generates this error: `The Project.toml of the package being tested must have a name and a UUID entry`

### Follow-up

Great! I was able to do `Pkg.test()`. I added to `CEXTokenizer.jl` these lines:

```
export tokenize_text
export urn_for_token
```

And was able to pass all the sample tests. 

Your short demo from the REPL worked as planned. 

Thanks! I will now do the GitHub upload, and come back for more help shortly. I appreciate your collaboration.
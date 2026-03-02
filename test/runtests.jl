using Test
using CEXTokenizer

@testset "CEXTokenizer" begin
    @testset "tokenize_text" begin
        s = "Μῆνιν ἄειδε θεὰ Πηληϊάδεω Ἀχιλῆος"
        toks = tokenize_text(s)
        @test toks[1] == "Μῆνιν"
        @test toks[2] == " "
        @test toks[3] == "ἄειδε"
        @test length(toks) == 9  # words + spaces
    end

    @testset "urn_for_token" begin
        orig = "urn:cts:greekLit:tlg0012.tlg001.perseus_grc2:1.1"
        @test urn_for_token(orig, 1) == "urn:cts:greekLit:tlg0012.tlg001.perseus_grc2.tokens:1.1.1"
        @test urn_for_token(orig, 2) == "urn:cts:greekLit:tlg0012.tlg001.perseus_grc2.tokens:1.1.2"
    end

    # TODO: Add integration test with a small .cex file in test/data/
    # e.g. write a tiny cex string to a temp file and call tokenize(...)
end
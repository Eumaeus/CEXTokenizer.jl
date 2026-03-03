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

@testset "analytical_tokenize helpers" begin
    @test is_word_token("Μῆνιν") == true
    @test is_word_token(" ") == false
    @test is_word_token(",") == false

    @test to_analytical_beta("Μῆνιν") == "mh=nin"
    @test to_analytical_beta("θεὰ") == "qea/"   # grave → acute after lowercasing
end

@testset "analytical_tokenize URNs" begin
    orig = "urn:cts:greekLit:tlg0012.tlg001.perseus_grc2:1.1"
    @test urn_for_token(orig, 3; exemplar="analytical_tokens") ==
          "urn:cts:greekLit:tlg0012.tlg001.perseus_grc2.analytical_tokens:1.1.3"
end

@testset "apostrophe handling in tokenize_text & is_word_token" begin
    @test is_word_token("τʼ") == true
    @test is_word_token("Ἀχιλλῆος'") == true
    @test is_word_token("word'") == true
    @test is_word_token("'") == false          # standalone
    @test is_word_token(",") == false

    s = "τʼ Ἀχιλλῆος' word' ,!"
    toks = tokenize_text(s)
    @test toks == ["τʼ", " ", "Ἀχιλλῆος'", " ", "word'", " ", ",", "!"]
end
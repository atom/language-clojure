describe "Clojure grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-clojure")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.clojure")

  it "parses the grammar", ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe "source.clojure"

  it "tokenizes functions in nested sexp", ->
    {tokens} = grammar.tokenizeLine "((foo bar) baz)"
    expect(tokens[0]).toEqual value: "(", scopes: ["source.clojure", "meta.expression.clojure", "punctuation.section.expression.begin.clojure"]
    expect(tokens[1]).toEqual value: "(", scopes: ["source.clojure", "meta.expression.clojure", "meta.expression.clojure", "punctuation.section.expression.begin.clojure"]
    expect(tokens[2]).toEqual value: "foo", scopes: ["source.clojure", "meta.expression.clojure", "meta.expression.clojure", "entity.name.function.clojure"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.clojure", "meta.expression.clojure", "meta.expression.clojure"]
    expect(tokens[4]).toEqual value: "bar", scopes: ["source.clojure", "meta.expression.clojure", "meta.expression.clojure", "meta.symbol.clojure"]
    expect(tokens[5]).toEqual value: ")", scopes: ["source.clojure", "meta.expression.clojure", "meta.expression.clojure", "punctuation.section.expression.end.clojure"]
    expect(tokens[6]).toEqual value: " ", scopes: ["source.clojure", "meta.expression.clojure"]
    expect(tokens[7]).toEqual value: "baz", scopes: ["source.clojure", "meta.expression.clojure", "meta.symbol.clojure"]
    expect(tokens[8]).toEqual value: ")", scopes: ["source.clojure", "meta.expression.clojure", "punctuation.section.expression.end.clojure"]

  it "tokenizes maps used as functions", ->
    {tokens} = grammar.tokenizeLine "({:foo bar} :foo)"
    expect(tokens[0]).toEqual value: "(", scopes: ["source.clojure", "meta.expression.clojure", "punctuation.section.expression.begin.clojure"]
    expect(tokens[1]).toEqual value: "{", scopes: ["source.clojure", "meta.expression.clojure", "meta.map.clojure", "punctuation.section.map.begin.clojure"]
    expect(tokens[2]).toEqual value: ":foo", scopes: ["source.clojure", "meta.expression.clojure", "meta.map.clojure", "constant.keyword.clojure"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.clojure", "meta.expression.clojure", "meta.map.clojure"]
    expect(tokens[4]).toEqual value: "bar", scopes: ["source.clojure", "meta.expression.clojure", "meta.map.clojure", "meta.symbol.clojure"]
    expect(tokens[5]).toEqual value: "}", scopes: ["source.clojure", "meta.expression.clojure", "meta.map.clojure", "punctuation.section.map.end.clojure"]
    expect(tokens[6]).toEqual value: " ", scopes: ["source.clojure", "meta.expression.clojure"]
    expect(tokens[7]).toEqual value: ":foo", scopes: ["source.clojure", "meta.expression.clojure", "constant.keyword.clojure"]
    expect(tokens[8]).toEqual value: ")", scopes: ["source.clojure", "meta.expression.clojure", "punctuation.section.expression.end.clojure"]

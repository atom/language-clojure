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

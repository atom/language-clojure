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

  it "tokenizes semi-colon comments", ->
    {tokens} = grammar.tokenizeLine "; clojure"
    expect(tokens[0]).toEqual value: ";", scopes: ["source.clojure", "comment.line.semicolon.clojure", "punctuation.definition.comment.clojure"]
    expect(tokens[1]).toEqual value: " clojure", scopes: ["source.clojure", "comment.line.semicolon.clojure"]

  it "tokenizes shebang comments", ->
    {tokens} = grammar.tokenizeLine "#!/usr/bin/env clojure"
    expect(tokens[0]).toEqual value: "#!", scopes: ["source.clojure", "comment.line.semicolon.clojure", "punctuation.definition.comment.shebang.clojure"]
    expect(tokens[1]).toEqual value: "/usr/bin/env clojure", scopes: ["source.clojure", "comment.line.semicolon.clojure"]

  it "tokenizes strings", ->
    {tokens} = grammar.tokenizeLine '"foo bar"'
    expect(tokens[0]).toEqual value: '"', scopes: ["source.clojure", "string.quoted.double.clojure", "punctuation.definition.string.begin.clojure"]
    expect(tokens[1]).toEqual value: 'foo bar', scopes: ["source.clojure", "string.quoted.double.clojure"]
    expect(tokens[2]).toEqual value: '"', scopes: ["source.clojure", "string.quoted.double.clojure", "punctuation.definition.string.end.clojure"]

  it "tokenizes character escape sequences", ->
    {tokens} = grammar.tokenizeLine '"\\n"'
    expect(tokens[0]).toEqual value: '"', scopes: ["source.clojure", "string.quoted.double.clojure", "punctuation.definition.string.begin.clojure"]
    expect(tokens[1]).toEqual value: '\\n', scopes: ["source.clojure", "string.quoted.double.clojure", "constant.character.escape.clojure"]
    expect(tokens[2]).toEqual value: '"', scopes: ["source.clojure", "string.quoted.double.clojure", "punctuation.definition.string.end.clojure"]

  it "tokenizes regexes", ->
    {tokens} = grammar.tokenizeLine '#"foo"'
    expect(tokens[0]).toEqual value: '#"', scopes: ["source.clojure", "string.regexp.clojure"]
    expect(tokens[1]).toEqual value: 'foo', scopes: ["source.clojure", "string.regexp.clojure"]
    expect(tokens[2]).toEqual value: '"', scopes: ["source.clojure", "string.regexp.clojure"]

  it "tokenizes backslash escape character in regexes", ->
    {tokens} = grammar.tokenizeLine '#"\\" "/"'
    expect(tokens[1]).toEqual value: "\\", scopes: ['source.clojure', 'string.regexp.clojure', 'constant.character.escape.backslash.clojure']
    expect(tokens[2]).toEqual value: '"', scopes: ['source.clojure', 'string.regexp.clojure']
    expect(tokens[4]).toEqual value: '"', scopes: ['source.clojure', 'string.quoted.double.clojure', 'punctuation.definition.string.begin.clojure']
    expect(tokens[5]).toEqual value: "/", scopes: ['source.clojure', 'string.quoted.double.clojure']
    expect(tokens[6]).toEqual value: '"', scopes: ['source.clojure', 'string.quoted.double.clojure', 'punctuation.definition.string.end.clojure']

  it "tokenizes numerics", ->
    numbers =
      "constant.numeric.ratio.clojure": ["1/2", "123/456"]
      "constant.numeric.arbitrary-radix.clojure": ["2R1011", "16rDEADBEEF"]
      "constant.numeric.hexadecimal.clojure": ["0xDEADBEEF", "0XDEADBEEF"]
      "constant.numeric.octal.clojure": ["0123"]
      "constant.numeric.bigdecimal.clojure": ["123.456M"]
      "constant.numeric.double.clojure": ["123.45", "123.45e6", "123.45E6"]
      "constant.numeric.bigint.clojure": ["123N"]
      "constant.numeric.long.clojure": ["123", "12321"]

    for scope, nums of numbers
      for num in nums
        {tokens} = grammar.tokenizeLine num
        expect(tokens[0]).toEqual value: num, scopes: ["source.clojure", scope]

  it "tokenizes booleans", ->
    booleans =
      "constant.language.boolean.clojure": ["true", "false"]

    for scope, bools of booleans
      for bool in bools
        {tokens} = grammar.tokenizeLine bool
        expect(tokens[0]).toEqual value: bool, scopes: ["source.clojure", scope]

  it "tokenizes nil", ->
    {tokens} = grammar.tokenizeLine "nil"
    expect(tokens[0]).toEqual value: "nil", scopes: ["source.clojure", "constant.language.nil.clojure"]

  it "tokenizes keywords", ->
    tests =
      "meta.expression.clojure": ["(:foo)"]
      "meta.map.clojure": ["{:foo}"]
      "meta.vector.clojure": ["[:foo]"]
      "meta.quoted-expression.clojure": ["'(:foo)", "`(:foo)"]

    for metaScope, lines of tests
      for line in lines
        {tokens} = grammar.tokenizeLine line
        expect(tokens[1]).toEqual value: ":foo", scopes: ["source.clojure", metaScope, "constant.keyword.clojure"]

  it "tokenizes keyfns (keyword control)", ->
    keyfns = ["declare", "declare-", "ns", "in-ns", "import", "use", "require", "load", "compile", "def", "defn", "defn-", "defmacro"]

    for keyfn in keyfns
      {tokens} = grammar.tokenizeLine "(#{keyfn})"
      expect(tokens[1]).toEqual value: keyfn, scopes: ["source.clojure", "meta.expression.clojure", "keyword.control.clojure"]

  it "tokenizes keyfns (storage control)", ->
    keyfns = ["if", "when", "for", "cond", "do", "let", "binding", "loop", "recur", "fn", "throw", "try", "catch", "finally", "case"]

    for keyfn in keyfns
      {tokens} = grammar.tokenizeLine "(#{keyfn})"
      expect(tokens[1]).toEqual value: keyfn, scopes: ["source.clojure", "meta.expression.clojure", "storage.control.clojure"]

  it "tokenizes global definitions", ->
    {tokens} = grammar.tokenizeLine "(def foo 'bar)"
    expect(tokens[1]).toEqual value: "def", scopes: ["source.clojure", "meta.expression.clojure", "meta.definition.global.clojure", "keyword.control.clojure"]
    expect(tokens[3]).toEqual value: "foo", scopes: ["source.clojure", "meta.expression.clojure", "meta.definition.global.clojure", "entity.global.clojure"]

  it "tokenizes dynamic variables", ->
    mutables = ["*ns*", "*foo-bar*"]

    for mutable in mutables
      {tokens} = grammar.tokenizeLine mutable
      expect(tokens[0]).toEqual value: mutable, scopes: ["source.clojure", "meta.symbol.dynamic.clojure"]

  it "tokenizes metadata", ->
    {tokens} = grammar.tokenizeLine "^Foo"
    expect(tokens[0]).toEqual value: "^", scopes: ["source.clojure", "meta.metadata.simple.clojure"]
    expect(tokens[1]).toEqual value: "Foo", scopes: ["source.clojure", "meta.metadata.simple.clojure", "meta.symbol.clojure"]

    {tokens} = grammar.tokenizeLine "^{:foo true}"
    expect(tokens[0]).toEqual value: "^{", scopes: ["source.clojure", "meta.metadata.map.clojure", "punctuation.section.metadata.map.begin.clojure"]
    expect(tokens[1]).toEqual value: ":foo", scopes: ["source.clojure", "meta.metadata.map.clojure", "constant.keyword.clojure"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.clojure", "meta.metadata.map.clojure"]
    expect(tokens[3]).toEqual value: "true", scopes: ["source.clojure", "meta.metadata.map.clojure", "constant.language.boolean.clojure"]
    expect(tokens[4]).toEqual value: "}", scopes: ["source.clojure", "meta.metadata.map.clojure", "punctuation.section.metadata.map.end.trailing.clojure"]

  it "tokenizes functions", ->
    expressions = ["(foo)", "(foo 1 10)"]

    for expr in expressions
      {tokens} = grammar.tokenizeLine expr
      expect(tokens[1]).toEqual value: "foo", scopes: ["source.clojure", "meta.expression.clojure", "entity.name.function.clojure"]

  it "tokenizes vars", ->
    {tokens} = grammar.tokenizeLine "(func #'foo)"
    expect(tokens[2]).toEqual value: " #", scopes: ["source.clojure", "meta.expression.clojure"]
    expect(tokens[3]).toEqual value: "'foo", scopes: ["source.clojure", "meta.expression.clojure", "meta.var.clojure"]

  it "tokenizes symbols", ->
    {tokens} = grammar.tokenizeLine "foo/bar"
    expect(tokens[0]).toEqual value: "foo", scopes: ["source.clojure", "meta.symbol.namespace.clojure"]
    expect(tokens[1]).toEqual value: "/", scopes: ["source.clojure"]
    expect(tokens[2]).toEqual value: "bar", scopes: ["source.clojure", "meta.symbol.clojure"]

  it "tokenizes trailing whitespace", ->
    {tokens} = grammar.tokenizeLine "   \n"
    expect(tokens[0]).toEqual value: "   \n", scopes: ["source.clojure", "invalid.trailing-whitespace"]

  testMetaSection = (metaScope, puncScope, startsWith, endsWith) ->
    # Entire expression on one line.
    {tokens} = grammar.tokenizeLine "#{startsWith}foo, bar#{endsWith}"

    [start, mid..., end, after] = tokens

    expect(start).toEqual value: startsWith, scopes: ["source.clojure", "meta.#{metaScope}.clojure", "punctuation.section.#{puncScope}.begin.clojure"]
    expect(end).toEqual value: endsWith, scopes: ["source.clojure", "meta.#{metaScope}.clojure", "punctuation.section.#{puncScope}.end.trailing.clojure"]

    for token in mid
      expect(token.scopes.slice(0, 2)).toEqual ["source.clojure", "meta.#{metaScope}.clojure"]

    # Expression broken over multiple lines.
    tokens = grammar.tokenizeLines("#{startsWith}foo\n bar#{endsWith}")

    [start, mid..., after] = tokens[0]

    expect(start).toEqual value: startsWith, scopes: ["source.clojure", "meta.#{metaScope}.clojure", "punctuation.section.#{puncScope}.begin.clojure"]

    for token in mid
      expect(token.scopes.slice(0, 2)).toEqual ["source.clojure", "meta.#{metaScope}.clojure"]

    [mid..., end, after] = tokens[1]

    expect(end).toEqual value: endsWith, scopes: ["source.clojure", "meta.#{metaScope}.clojure", "punctuation.section.#{puncScope}.end.trailing.clojure"]

    for token in mid
      expect(token.scopes.slice(0, 2)).toEqual ["source.clojure", "meta.#{metaScope}.clojure"]

  it "tokenizes expressions", ->
    testMetaSection "expression", "expression", "(", ")"

  it "tokenizes quoted expressions", ->
    testMetaSection "quoted-expression", "expression", "'(", ")"
    testMetaSection "quoted-expression", "expression", "`(", ")"

  it "tokenizes vectors", ->
    testMetaSection "vector", "vector", "[", "]"

  it "tokenizes maps", ->
    testMetaSection "map", "map", "{", "}"

  it "tokenizes sets", ->
    testMetaSection "set", "set", "\#{", "}"

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
    expect(tokens[8]).toEqual value: ")", scopes: ["source.clojure", "meta.expression.clojure", "punctuation.section.expression.end.trailing.clojure"]

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
    expect(tokens[8]).toEqual value: ")", scopes: ["source.clojure", "meta.expression.clojure", "punctuation.section.expression.end.trailing.clojure"]

  it "tokenizes sets used in functions", ->
    {tokens} = grammar.tokenizeLine "(\#{:foo :bar})"
    expect(tokens[0]).toEqual value: "(", scopes: ["source.clojure", "meta.expression.clojure", "punctuation.section.expression.begin.clojure"]
    expect(tokens[1]).toEqual value: "\#{", scopes: ["source.clojure", "meta.expression.clojure", "meta.set.clojure", "punctuation.section.set.begin.clojure"]
    expect(tokens[2]).toEqual value: ":foo", scopes: ["source.clojure", "meta.expression.clojure", "meta.set.clojure", "constant.keyword.clojure"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.clojure", "meta.expression.clojure", "meta.set.clojure"]
    expect(tokens[4]).toEqual value: ":bar", scopes: ["source.clojure", "meta.expression.clojure", "meta.set.clojure", "constant.keyword.clojure"]
    expect(tokens[5]).toEqual value: "}", scopes: ["source.clojure", "meta.expression.clojure", "meta.set.clojure", "punctuation.section.set.end.trailing.clojure"]
    expect(tokens[6]).toEqual value: ")", scopes: ["source.clojure", "meta.expression.clojure", "punctuation.section.expression.end.trailing.clojure"]

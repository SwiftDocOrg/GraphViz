/**
 The following is an abstract grammar defining the DOT language.

 Terminals are shown in bold font and nonterminals in italics.
 Literal characters are given in single quotes.
 Parentheses ( and ) indicate grouping when needed.
 Square brackets [ and ] enclose optional items.
 Vertical bars | separate alternatives.

         graph    :    [ strict ] (graph | digraph) [ ID ] '{' stmt_list '}'
     stmt_list    :    [ stmt [ ';' ] stmt_list ]
          stmt    :    node_stmt
                  |    edge_stmt
                  |    attr_stmt
                  |    ID '=' ID
                  |    subgraph
     attr_stmt    :    (graph | node | edge) attr_list
     attr_list    :    '[' [ a_list ] ']' [ attr_list ]
        a_list    :    ID '=' ID [ (';' | ',') ] [ a_list ]
     edge_stmt    :    (node_id | subgraph) edgeRHS [ attr_list ]
       edgeRHS    :    edgeop (node_id | subgraph) [ edgeRHS ]
     node_stmt    :    node_id [ attr_list ]
       node_id    :    ID [ port ]
          port    :    ':' ID [ ':' compass_pt ]
                  |    ':' compass_pt
      subgraph    :    [ subgraph [ ID ] ] '{' stmt_list '}'
    compass_pt    :    (n | ne | e | se | s | sw | w | nw | c | _)
 */
enum DOT {
    /// The keywords node, edge, graph, digraph, subgraph, and strict are case-independent.
    static let keywords: Set<String> = [
        "node",
        "edge",
        "graph",
        "digraph",
        "subgraph",
        "strict"
    ]
}

let pp_build fmt (t : Hsa.build_timing) =
  Format.fprintf fmt
    "  assoc build  %8.3f ms@\n  node add     %8.3f ms@\n  edge add     %8.3f ms@\n  total build  %8.3f ms"
    t.association_build_ms t.node_addition_ms t.edge_addition_ms t.total_build_ms

let pp_analyze fmt (t : Hsa.analyze_timing) =
  Format.fprintf fmt
    "nodes: %d  edges: %d@\nbuild:@\n%a@\nfixpoint     %8.3f ms@\ntotal        %8.3f ms"
    t.node_count t.edge_count
    pp_build t.build
    t.fixpoint_ms t.total_ms

let report t =
  Format.printf "%a@." pp_analyze t

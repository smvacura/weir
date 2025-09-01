import Lake
open Lake DSL

package «lean-networking» where
  -- add package configuration options here

lean_lib «LeanNetworking» where
  -- add library configuration options here

@[default_target]
lean_exe «lean-networking» where
  root := `Main

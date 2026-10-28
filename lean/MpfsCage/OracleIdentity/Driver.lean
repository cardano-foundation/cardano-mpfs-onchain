import MpfsCage.OracleIdentity.Corpus

/-- Run with `lake env lean --run MpfsCage/OracleIdentity/Driver.lean`.
    `--corpus` emits JSON-lines inputs; otherwise stdin holds one scenario. -/
def main (args : List String) : IO UInt32 := do
  let stdout ← IO.getStdout
  if args = ["--corpus"] then
    for s in OracleIdentity.Corpus.witnessCorpus ++ OracleIdentity.Corpus.mutantCorpus do
      stdout.putStrLn (Lean.toJson s).compress
    return 0
  if !args.isEmpty then
    (← IO.getStderr).putStrLn "expected no arguments or --corpus"
    return 2
  let input ← (← IO.getStdin).readToEnd
  let result := do
    let json ← Lean.Json.parse input
    let scenario ← Lean.fromJson? (α := OracleIdentity.Scenario) json
    OracleIdentity.runScenario scenario
  match result with
  | .ok json =>
      stdout.putStrLn json.compress
      return 0
  | .error reason =>
      stdout.putStrLn (Lean.Json.mkObj [("error", Lean.toJson reason)]).compress
      return 1

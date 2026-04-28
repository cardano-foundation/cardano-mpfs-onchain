import Lake
open Lake DSL

package «mpfs-cage-blaster» where
  moreGlobalServerArgs := #["--threads=4"]
  moreLeanArgs := #["--threads=4"]

require «CardanoLedgerApi» from git
  "https://github.com/input-output-hk/CardanoLedgerApiBlaster" @ "main"

@[default_target]
lean_lib MpfsCageBlaster where

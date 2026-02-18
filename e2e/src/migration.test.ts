import { describe, it, beforeAll } from "vitest";
import {
  type LucidEvolution,
  getAddressDetails,
} from "@lucid-evolution/lucid";
import { waitForYaci, initLucid, createTestWallet } from "./setup.js";
import { loadValidator } from "./blueprint.js";
import { cage } from "./cage.js";

const EMPTY_ROOT =
  "0000000000000000000000000000000000000000000000000000000000000000";
const MODIFIED_ROOT =
  "484dee386bcb51e285896271048baf6ea4396b2ee95be6fd29a92a0eeb8462ea";
const INSERT_KEY = "3432";
const INSERT_VALUE = "3432";

describe("MPF Cage Migration E2E", () => {
  let lucid: LucidEvolution;
  let walletAddress: string;
  let ownerKeyHash: string;

  beforeAll(async () => {
    await waitForYaci();
    lucid = await initLucid();
    const wallet = await createTestWallet(lucid);
    walletAddress = wallet.address;
    const details = getAddressDetails(walletAddress);
    ownerKeyHash = details.paymentCredential!.hash;
  });

  const PROCESS_TIME = 600_000n; // 10 minutes
  const RETRACT_TIME = 600_000n;

  it("mint and end on single version", async () => {
    await cage(
      lucid,
      loadValidator(0),
      ownerKeyHash,
      walletAddress,
      PROCESS_TIME,
      RETRACT_TIME,
    )
      .mint()
      .end();
  });

  it("modify with fee enforces refund to requester", async () => {
    await cage(
      lucid,
      loadValidator(0),
      ownerKeyHash,
      walletAddress,
      PROCESS_TIME,
      RETRACT_TIME,
    )
      .mint({ maxFee: 500_000n })
      .request(INSERT_KEY, INSERT_VALUE, { fee: 500_000n })
      .modify(MODIFIED_ROOT)
      .end();
  });

  // Migration e2e skipped: the migration tx attaches 3 validator scripts
  // (old mint, new mint, old spend) which exceeds the 16KB tx size limit.
  // Migration is covered by Aiken unit tests. Production migrations will
  // need reference scripts to stay within the limit.

  it("reject discards request after retract window", async () => {
    const shortProcess = 10_000n;
    const shortRetract = 10_000n;
    await cage(
      lucid,
      loadValidator(0),
      ownerKeyHash,
      walletAddress,
      shortProcess,
      shortRetract,
    )
      .mint()
      .request(INSERT_KEY, INSERT_VALUE)
      .waitForPhase3()
      .reject()
      .end();
  });
});

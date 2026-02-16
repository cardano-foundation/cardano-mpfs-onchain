import {
  Blockfrost,
  Lucid,
  type LucidEvolution,
  generateSeedPhrase,
} from "@lucid-evolution/lucid";

const YACI_HOST = process.env.YACI_HOST ?? "localhost";

const STORE_URL = `http://${YACI_HOST}:8080/api/v1`;
const ADMIN_URL = `http://${YACI_HOST}:10000`;

export async function waitForYaci(
  retries = 60,
  interval = 2000,
): Promise<void> {
  for (let i = 0; i < retries; i++) {
    try {
      const res = await fetch(`${STORE_URL}/epochs/latest`);
      if (res.ok) return;
    } catch {
      // not ready yet
    }
    await new Promise((r) => setTimeout(r, interval));
  }
  throw new Error("Yaci DevKit failed to become ready");
}

export async function topupAddress(
  address: string,
  adaAmount: number,
): Promise<void> {
  const res = await fetch(
    `${ADMIN_URL}/local-cluster/api/addresses/topup`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ address, adaAmount }),
    },
  );
  if (!res.ok) {
    throw new Error(`Topup failed: ${res.status} ${await res.text()}`);
  }
  // Wait for the topup to be visible
  await new Promise((r) => setTimeout(r, 3000));
}

export async function initLucid(): Promise<LucidEvolution> {
  const provider = new Blockfrost(STORE_URL, "yaci");
  return Lucid(provider, "Custom");
}

export async function createTestWallet(lucid: LucidEvolution): Promise<{
  seedPhrase: string;
  address: string;
}> {
  const seedPhrase = generateSeedPhrase();
  lucid.selectWallet.fromSeed(seedPhrase);
  const address = await lucid.wallet().address();
  await topupAddress(address, 100);
  return { seedPhrase, address };
}

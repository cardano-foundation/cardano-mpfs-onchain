-- |
-- Module      : Cardano.MPFS.Cage.Proof
-- Description : Aiken-compatible proof serialization
-- License     : Apache-2.0
--
-- Converts 'MPFProof' (from @mts:mpf@) to the on-chain
-- 'ProofStep' type used in 'UpdateRedeemer'.
--
-- Steps are reversed from the library's leaf-to-root
-- order to the root-to-leaf order expected on-chain.
module Cardano.MPFS.Cage.Proof
    ( -- * Conversion to on-chain types
      toProofSteps
    ) where

import Data.Map.Strict qualified as Map
import MPF.Hashes
    ( MPFHash
    , merkleProof
    , nibbleBytes
    , packHexKey
    , renderMPFHash
    )
import MPF.Interface (HexDigit (..))
import MPF.Proof.Insertion
    ( MPFProof (..)
    , MPFProofStep (..)
    )

import Cardano.MPFS.Cage.OnChain
    ( Neighbor (..)
    , ProofStep (..)
    )

-- | Convert an 'MPFProof' to on-chain 'ProofStep's.
--
-- Steps are reversed from leaf-to-root storage order
-- to root-to-leaf (matching the on-chain expectation).
toProofSteps
    :: MPFProof MPFHash
    -- ^ Proof produced by an insert\/delete\/update
    -> [ProofStep]
toProofSteps MPFProof{mpfProofSteps} =
    map convertStep (reverse mpfProofSteps)

-- | Convert a single 'MPFProofStep' to an on-chain
-- 'ProofStep'.
convertStep
    :: MPFProofStep MPFHash -> ProofStep
convertStep
    ProofStepBranch
        { psbJump
        , psbPosition
        , psbSiblingHashes
        } =
        let skip =
                fromIntegral (length psbJump)
            sparseChildren =
                buildSparse psbSiblingHashes
            pos =
                fromIntegral
                    (unHexDigit psbPosition)
            neighborHashes =
                map renderMPFHash
                    $ merkleProof sparseChildren pos
            neighbors = mconcat neighborHashes
        in  Branch skip neighbors
convertStep
    ProofStepFork
        { psfBranchJump
        , psfNeighborPrefix
        , psfNeighborIndex
        , psfMerkleRoot
        } =
        let skip =
                fromIntegral (length psfBranchJump)
            nibble =
                fromIntegral
                    (unHexDigit psfNeighborIndex)
            prefix =
                nibbleBytes psfNeighborPrefix
            root = renderMPFHash psfMerkleRoot
        in  Fork
                skip
                Neighbor
                    { neighborNibble = nibble
                    , neighborPrefix = prefix
                    , neighborRoot = root
                    }
convertStep
    ProofStepLeaf
        { pslBranchJump
        , pslNeighborKeyPath
        , pslNeighborValueDigest
        } =
        let skip =
                fromIntegral (length pslBranchJump)
            key =
                packHexKey pslNeighborKeyPath
            value =
                renderMPFHash pslNeighborValueDigest
        in  Leaf skip key value

-- | Build a sparse 16-element array from sibling
-- hashes for 'merkleProof'.
buildSparse
    :: [(HexDigit, MPFHash)] -> [Maybe MPFHash]
buildSparse siblings =
    let m = Map.fromList siblings
    in  [ Map.lookup (HexDigit n) m
        | n <- [0 .. 15]
        ]

{-# LANGUAGE OverloadedStrings #-}

module Cardano.MPFS.OnChain.Types
    ( -- * On-chain datum\/redeemer types
      CageDatum (..)
    , MintRedeemer (..)
    , Mint (..)
    , Migration (..)
    , UpdateRedeemer (..)

      -- * On-chain domain types
    , OnChainTokenId (..)
    , OnChainOperation (..)
    , OnChainRoot (..)
    , OnChainRequest (..)
    , OnChainTokenState (..)
    , OnChainTxOutRef (..)

      -- * Proof steps (Aiken MPF proof encoding)
    , ProofStep (..)
    , Neighbor (..)
    ) where

import Data.ByteString (ByteString)
import PlutusCore.Data (Data (..))
import PlutusTx.Builtins.Internal
    ( BuiltinByteString (..)
    , BuiltinData (..)
    )
import PlutusTx.IsData.Class
    ( FromData (..)
    , ToData (..)
    , UnsafeFromData (..)
    )

-- ---------------------------------------------------------
-- On-chain domain types (Plutus primitives)
-- ---------------------------------------------------------

newtype OnChainTokenId = OnChainTokenId
    { unOnChainTokenId :: BuiltinByteString
    }
    deriving stock (Show, Eq)

data OnChainTxOutRef = OnChainTxOutRef
    { txOutRefId :: !BuiltinByteString
    , txOutRefIdx :: !Integer
    }
    deriving stock (Show, Eq)

newtype OnChainRoot = OnChainRoot
    { unOnChainRoot :: ByteString
    }
    deriving stock (Show, Eq)

data OnChainOperation
    = OpInsert !ByteString
    | OpDelete !ByteString
    | OpUpdate !ByteString !ByteString
    deriving stock (Show, Eq)

data OnChainRequest = OnChainRequest
    { requestToken :: !OnChainTokenId
    , requestOwner :: !BuiltinByteString
    , requestKey :: !ByteString
    , requestValue :: !OnChainOperation
    , requestTip :: !Integer
    , requestSubmittedAt :: !Integer
    }
    deriving stock (Show, Eq)

data OnChainTokenState = OnChainTokenState
    { stateOwner :: !BuiltinByteString
    , stateRoot :: !OnChainRoot
    , stateTip :: !Integer
    , stateProcessTime :: !Integer
    , stateRetractTime :: !Integer
    }
    deriving stock (Show, Eq)

-- ---------------------------------------------------------
-- On-chain-only types (datum / redeemer wrappers)
-- ---------------------------------------------------------

data CageDatum
    = RequestDatum !OnChainRequest
    | StateDatum !OnChainTokenState
    deriving stock (Show, Eq)

data MintRedeemer
    = Minting !Mint
    | Migrating !Migration
    | Burning
    deriving stock (Show, Eq)

newtype Mint = Mint
    { mintAsset :: OnChainTxOutRef
    }
    deriving stock (Show, Eq)

data Migration = Migration
    { migrationOldPolicy :: !BuiltinByteString
    , migrationTokenId :: !OnChainTokenId
    }
    deriving stock (Show, Eq)

data UpdateRedeemer
    = End
    | Contribute !OnChainTxOutRef
    | Modify ![[ProofStep]]
    | Retract !OnChainTxOutRef
    | Reject
    deriving stock (Show, Eq)

data ProofStep
    = Branch
        { branchSkip :: !Integer
        , branchNeighbors :: !ByteString
        }
    | Fork
        { forkSkip :: !Integer
        , forkNeighbor :: !Neighbor
        }
    | Leaf
        { leafSkip :: !Integer
        , leafKey :: !ByteString
        , leafValue :: !ByteString
        }
    deriving stock (Show, Eq)

data Neighbor = Neighbor
    { neighborNibble :: !Integer
    , neighborPrefix :: !ByteString
    , neighborRoot :: !ByteString
    }
    deriving stock (Show, Eq)

-- ---------------------------------------------------------
-- Helpers for manual Data construction
-- ---------------------------------------------------------

mkD :: Data -> BuiltinData
mkD = BuiltinData

unD :: BuiltinData -> Data
unD (BuiltinData d) = d

bsToD :: ByteString -> Data
bsToD = B

bsFromD :: Data -> Maybe ByteString
bsFromD (B bs) = Just bs
bsFromD _ = Nothing

bbsToD :: BuiltinByteString -> Data
bbsToD (BuiltinByteString bs) = B bs

bbsFromD :: Data -> Maybe BuiltinByteString
bbsFromD (B bs) = Just (BuiltinByteString bs)
bbsFromD _ = Nothing

-- ---------------------------------------------------------
-- ToData / FromData instances
-- ---------------------------------------------------------

instance ToData OnChainTokenId where
    toBuiltinData (OnChainTokenId bbs) =
        mkD $ Constr 0 [bbsToD bbs]

instance FromData OnChainTokenId where
    fromBuiltinData bd = case unD bd of
        Constr 0 [x] ->
            OnChainTokenId <$> bbsFromD x
        _ -> Nothing

instance UnsafeFromData OnChainTokenId where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [x] -> case bbsFromD x of
            Just bbs -> OnChainTokenId bbs
            _ ->
                error
                    "unsafeFromBuiltinData: OnChainTokenId"
        _ ->
            error
                "unsafeFromBuiltinData: OnChainTokenId"

instance ToData OnChainTxOutRef where
    toBuiltinData OnChainTxOutRef{..} =
        mkD
            $ Constr
                0
                [bbsToD txOutRefId, I txOutRefIdx]

instance FromData OnChainTxOutRef where
    fromBuiltinData bd = case unD bd of
        Constr 0 [tid, I idx] ->
            OnChainTxOutRef
                <$> bbsFromD tid
                <*> pure idx
        _ -> Nothing

instance UnsafeFromData OnChainTxOutRef where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [B tid, I idx] ->
            OnChainTxOutRef
                (BuiltinByteString tid)
                idx
        _ ->
            error
                "unsafeFromBuiltinData: OnChainTxOutRef"

instance ToData OnChainOperation where
    toBuiltinData (OpInsert v) =
        mkD $ Constr 0 [bsToD v]
    toBuiltinData (OpDelete v) =
        mkD $ Constr 1 [bsToD v]
    toBuiltinData (OpUpdate old new) =
        mkD $ Constr 2 [bsToD old, bsToD new]

instance FromData OnChainOperation where
    fromBuiltinData bd = case unD bd of
        Constr 0 [v] -> OpInsert <$> bsFromD v
        Constr 1 [v] -> OpDelete <$> bsFromD v
        Constr 2 [o, n] ->
            OpUpdate <$> bsFromD o <*> bsFromD n
        _ -> Nothing

instance UnsafeFromData OnChainOperation where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [B v] -> OpInsert v
        Constr 1 [B v] -> OpDelete v
        Constr 2 [B o, B n] -> OpUpdate o n
        _ ->
            error
                "unsafeFromBuiltinData: OnChainOperation"

instance ToData OnChainRoot where
    toBuiltinData (OnChainRoot bs) = mkD $ bsToD bs

instance FromData OnChainRoot where
    fromBuiltinData bd =
        OnChainRoot <$> bsFromD (unD bd)

instance UnsafeFromData OnChainRoot where
    unsafeFromBuiltinData bd = case unD bd of
        B bs -> OnChainRoot bs
        _ ->
            error
                "unsafeFromBuiltinData: OnChainRoot"

instance ToData OnChainRequest where
    toBuiltinData OnChainRequest{..} =
        mkD
            $ Constr
                0
                [ unD (toBuiltinData requestToken)
                , bbsToD requestOwner
                , bsToD requestKey
                , unD (toBuiltinData requestValue)
                , I requestTip
                , I requestSubmittedAt
                ]

instance FromData OnChainRequest where
    fromBuiltinData bd = case unD bd of
        Constr
            0
            [tok, own, k, val, I tip, I sub] -> do
                requestToken <-
                    fromBuiltinData (mkD tok)
                requestOwner <- bbsFromD own
                requestKey <- bsFromD k
                requestValue <-
                    fromBuiltinData (mkD val)
                let requestTip = tip
                    requestSubmittedAt = sub
                Just OnChainRequest{..}
        _ -> Nothing

instance UnsafeFromData OnChainRequest where
    unsafeFromBuiltinData bd = case unD bd of
        Constr
            0
            [tok, B own, B k, val, I tip, I sub] ->
                OnChainRequest
                    { requestToken =
                        unsafeFromBuiltinData (mkD tok)
                    , requestOwner =
                        BuiltinByteString own
                    , requestKey = k
                    , requestValue =
                        unsafeFromBuiltinData (mkD val)
                    , requestTip = tip
                    , requestSubmittedAt = sub
                    }
        _ ->
            error
                "unsafeFromBuiltinData:\
                \ OnChainRequest"

instance ToData OnChainTokenState where
    toBuiltinData OnChainTokenState{..} =
        mkD
            $ Constr
                0
                [ bbsToD stateOwner
                , unD (toBuiltinData stateRoot)
                , I stateTip
                , I stateProcessTime
                , I stateRetractTime
                ]

instance FromData OnChainTokenState where
    fromBuiltinData bd = case unD bd of
        Constr 0 [own, r, I tip, I pt, I rt] -> do
            stateOwner <- bbsFromD own
            stateRoot <- fromBuiltinData (mkD r)
            let stateTip = tip
                stateProcessTime = pt
                stateRetractTime = rt
            Just OnChainTokenState{..}
        _ -> Nothing

instance UnsafeFromData OnChainTokenState where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [B own, r, I tip, I pt, I rt] ->
            OnChainTokenState
                { stateOwner =
                    BuiltinByteString own
                , stateRoot =
                    unsafeFromBuiltinData (mkD r)
                , stateTip = tip
                , stateProcessTime = pt
                , stateRetractTime = rt
                }
        _ ->
            error
                "unsafeFromBuiltinData:\
                \ OnChainTokenState"

instance ToData CageDatum where
    toBuiltinData (RequestDatum r) =
        mkD
            $ Constr 0 [unD (toBuiltinData r)]
    toBuiltinData (StateDatum s) =
        mkD
            $ Constr 1 [unD (toBuiltinData s)]

instance FromData CageDatum where
    fromBuiltinData bd = case unD bd of
        Constr 0 [d] ->
            RequestDatum
                <$> fromBuiltinData (mkD d)
        Constr 1 [d] ->
            StateDatum
                <$> fromBuiltinData (mkD d)
        _ -> Nothing

instance UnsafeFromData CageDatum where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [d] ->
            RequestDatum
                $ unsafeFromBuiltinData (mkD d)
        Constr 1 [d] ->
            StateDatum
                $ unsafeFromBuiltinData (mkD d)
        _ -> error "unsafeFromBuiltinData: CageDatum"

instance ToData Mint where
    toBuiltinData (Mint ref) =
        mkD $ Constr 0 [unD (toBuiltinData ref)]

instance FromData Mint where
    fromBuiltinData bd = case unD bd of
        Constr 0 [d] ->
            Mint <$> fromBuiltinData (mkD d)
        _ -> Nothing

instance UnsafeFromData Mint where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [d] ->
            Mint $ unsafeFromBuiltinData (mkD d)
        _ -> error "unsafeFromBuiltinData: Mint"

instance ToData Migration where
    toBuiltinData Migration{..} =
        mkD
            $ Constr
                0
                [ bbsToD migrationOldPolicy
                , unD
                    (toBuiltinData migrationTokenId)
                ]

instance FromData Migration where
    fromBuiltinData bd = case unD bd of
        Constr 0 [pol, tid] -> do
            migrationOldPolicy <- bbsFromD pol
            migrationTokenId <-
                fromBuiltinData (mkD tid)
            Just Migration{..}
        _ -> Nothing

instance UnsafeFromData Migration where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [B pol, tid] ->
            Migration
                { migrationOldPolicy =
                    BuiltinByteString pol
                , migrationTokenId =
                    unsafeFromBuiltinData (mkD tid)
                }
        _ ->
            error
                "unsafeFromBuiltinData: Migration"

instance ToData MintRedeemer where
    toBuiltinData (Minting m) =
        mkD $ Constr 0 [unD (toBuiltinData m)]
    toBuiltinData (Migrating m) =
        mkD $ Constr 1 [unD (toBuiltinData m)]
    toBuiltinData Burning =
        mkD $ Constr 2 []

instance FromData MintRedeemer where
    fromBuiltinData bd = case unD bd of
        Constr 0 [d] ->
            Minting <$> fromBuiltinData (mkD d)
        Constr 1 [d] ->
            Migrating <$> fromBuiltinData (mkD d)
        Constr 2 [] -> Just Burning
        _ -> Nothing

instance UnsafeFromData MintRedeemer where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [d] ->
            Minting $ unsafeFromBuiltinData (mkD d)
        Constr 1 [d] ->
            Migrating
                $ unsafeFromBuiltinData (mkD d)
        Constr 2 [] -> Burning
        _ ->
            error
                "unsafeFromBuiltinData: MintRedeemer"

instance ToData Neighbor where
    toBuiltinData Neighbor{..} =
        mkD
            $ Constr
                0
                [ I neighborNibble
                , bsToD neighborPrefix
                , bsToD neighborRoot
                ]

instance FromData Neighbor where
    fromBuiltinData bd = case unD bd of
        Constr 0 [I nib, pfx, rt] ->
            Neighbor nib
                <$> bsFromD pfx
                <*> bsFromD rt
        _ -> Nothing

instance UnsafeFromData Neighbor where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [I nib, B pfx, B rt] ->
            Neighbor nib pfx rt
        _ -> error "unsafeFromBuiltinData: Neighbor"

instance ToData ProofStep where
    toBuiltinData Branch{..} =
        mkD
            $ Constr
                0
                [ I branchSkip
                , bsToD branchNeighbors
                ]
    toBuiltinData Fork{..} =
        mkD
            $ Constr
                1
                [ I forkSkip
                , unD (toBuiltinData forkNeighbor)
                ]
    toBuiltinData Leaf{..} =
        mkD
            $ Constr
                2
                [ I leafSkip
                , bsToD leafKey
                , bsToD leafValue
                ]

instance FromData ProofStep where
    fromBuiltinData bd = case unD bd of
        Constr 0 [I sk, nb] ->
            Branch sk <$> bsFromD nb
        Constr 1 [I sk, nd] ->
            Fork sk
                <$> fromBuiltinData (mkD nd)
        Constr 2 [I sk, k, v] ->
            Leaf sk <$> bsFromD k <*> bsFromD v
        _ -> Nothing

instance UnsafeFromData ProofStep where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [I sk, B nb] -> Branch sk nb
        Constr 1 [I sk, nd] ->
            Fork sk
                $ unsafeFromBuiltinData (mkD nd)
        Constr 2 [I sk, B k, B v] -> Leaf sk k v
        _ ->
            error "unsafeFromBuiltinData: ProofStep"

instance ToData UpdateRedeemer where
    toBuiltinData End = mkD $ Constr 0 []
    toBuiltinData (Contribute ref) =
        mkD $ Constr 1 [unD (toBuiltinData ref)]
    toBuiltinData (Modify proofs) =
        mkD
            $ Constr
                2
                [ List
                    ( map
                        ( List
                            . map
                                (unD . toBuiltinData)
                        )
                        proofs
                    )
                ]
    toBuiltinData (Retract ref) =
        mkD $ Constr 3 [unD (toBuiltinData ref)]
    toBuiltinData Reject = mkD $ Constr 4 []

instance FromData UpdateRedeemer where
    fromBuiltinData bd = case unD bd of
        Constr 0 [] -> Just End
        Constr 1 [d] ->
            Contribute <$> fromBuiltinData (mkD d)
        Constr 2 [List ps] ->
            Modify <$> traverse parseProof ps
          where
            parseProof (List steps) =
                traverse
                    (fromBuiltinData . mkD)
                    steps
            parseProof _ = Nothing
        Constr 3 [d] ->
            Retract <$> fromBuiltinData (mkD d)
        Constr 4 [] -> Just Reject
        _ -> Nothing

instance UnsafeFromData UpdateRedeemer where
    unsafeFromBuiltinData bd = case unD bd of
        Constr 0 [] -> End
        Constr 1 [d] ->
            Contribute
                $ unsafeFromBuiltinData (mkD d)
        Constr 2 [List ps] ->
            Modify $ map parseProof ps
          where
            parseProof (List steps) =
                map (unsafeFromBuiltinData . mkD) steps
            parseProof _ =
                error
                    "unsafeFromBuiltinData:\
                    \ UpdateRedeemer"
        Constr 3 [d] ->
            Retract
                $ unsafeFromBuiltinData (mkD d)
        Constr 4 [] -> Reject
        _ ->
            error
                "unsafeFromBuiltinData:\
                \ UpdateRedeemer"

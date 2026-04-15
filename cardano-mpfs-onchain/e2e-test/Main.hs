module Main (main) where

import Test.Hspec (hspec)

import CageE2ESpec qualified

main :: IO ()
main = hspec CageE2ESpec.spec

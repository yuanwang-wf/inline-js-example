{-# LANGUAGE TemplateHaskell #-}

module Main where

import Hedgehog
import Hedgehog.Main
import InlineJsExample

prop_test :: Property
prop_test = property $ do
  doInlineJsExample === "InlineJsExample"

main :: IO ()
main = defaultMain [checkParallel $$(discover)]

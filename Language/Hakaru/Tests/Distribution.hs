{-# LANGUAGE BangPatterns #-}

module Language.Hakaru.Tests.ImportanceSampler where

import Data.Dynamic
import Language.Hakaru.Distribution

import Test.QuickCheck.Monadic

testBeta = undefined
mu a b = a / (a + b)
var a b = a*b / ((sqr $ a + b) * (a + b + 1))
  where sqr x = x * x

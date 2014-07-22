{-# LANGUAGE BangPatterns #-}

module Language.Hakaru.Tests.Metropolis where

import Data.Dynamic

import Language.Hakaru.Lambda
import Language.Hakaru.Metropolis
import Language.Hakaru.Distribution (bern, normal, uniform, beta)
import Language.Hakaru.Util.Visual

import Test.QuickCheck.Monadic
import Distribution.TestSuite.QuickCheck

prog_mixture :: Measure Bool
prog_mixture = do
  c <- unconditioned (bern 0.5)
  _ <- conditioned (ifThenElse c (normal (lit (1 :: Double)) (lit 1))
                                 (uniform (lit 0) (lit 3)))
  return c

test_mixture :: IO [Bool]
test_mixture = mcmc prog_mixture [Just (toDyn (-2 :: Double))]

prog_multiple_conditions :: Measure Double
prog_multiple_conditions = do
  b <- unconditioned (beta 1 1)
  _ <- conditioned (bern b)
  _ <- conditioned (bern b)
  return b

test_multiple_conditions :: IO ()
test_multiple_conditions = do
  l <- mcmc prog_multiple_conditions [Just (toDyn True), Just (toDyn False)]
  viz 10000 ["beta"] (map return l)

prog_two_normals :: Measure Bool
prog_two_normals = unconditioned (bern 0.5) `bind` \coin ->
       ifThenElse coin (conditioned (normal 0 1))
                       (conditioned (normal 100 1)) `bind` \_ ->
       return coin

test_two_normals :: IO [Bool]
test_two_normals = mcmc prog_two_normals [Just (toDyn (1 :: Double))]

test_normal :: IO ()
test_normal = do
  l <- mcmc (unconditioned (normal 1 3)) [] :: IO [Double]
  viz 10000 ["normal"] (map return l)

{-# LANGUAGE RankNTypes, NoMonomorphismRestriction, BangPatterns #-}

module Examples.Tests where

import Types
import Data.Dynamic
import Language.Hakaru.ImportanceSampler

-- Some example/test programs in our language
test :: Measure Bool
test = do
  c <- unconditioned (bern 0.5)
  _ <- conditioned (ifThenElse c (normal (lit (1 :: Double)) (lit 1))
                                 (uniformC (lit 0) (lit 3)))
  return c

test_dup :: Measure (Bool, Bool)
test_dup = do
  let c = unconditioned (bern 0.5)
  x <- c
  y <- c
  return (x,y)

test_dbn :: Measure Bool
test_dbn = do
  s0 <- unconditioned (bern 0.75)
  s1 <- unconditioned (if s0 then bern 0.75 else bern 0.25)
  _  <- conditioned (if s1 then bern 0.9 else bern 0.1)
  s2 <- unconditioned (if s1 then bern 0.75 else bern 0.25)
  _  <- conditioned (if s2 then bern 0.9 else bern 0.1)
  return s2

test_hmm :: Integer -> Measure Bool
test_hmm n = do
  s <- unconditioned (bern 0.75) 
  loop_hmm n s

loop_hmm :: Integer -> (Bool -> Measure Bool)
loop_hmm !numLoops s = do
    _ <- conditioned (if s then bern 0.9 else bern 0.1)
    u <- unconditioned (if s then bern 0.75 else bern 0.25)
    if (numLoops > 1) then loop_hmm (numLoops - 1) u 
                      else return s

test_carRoadModel :: Measure (Double, Double)
test_carRoadModel = do
  speed <- unconditioned (uniformC (lit (5::Double)) (lit (15::Double)))
  let z0 = lit 0 
  _ <- conditioned (normal (z0 :: Double) (lit 1))
  z1 <- unconditioned (normal (z0 + speed) (lit 1))
  _ <- conditioned (normal z1 (lit 1))
  z2 <- unconditioned (normal (z1 + speed) (lit 1))	
  _ <- conditioned (normal z2 (lit 1))
  z3 <- unconditioned (normal (z2 + speed) (lit 1))	
  _ <- conditioned (normal z3 (lit 1))
  z4 <- unconditioned (normal (z3 + speed) (lit 1))	
  return (z4, z3)

test_categorical :: Measure Bool
test_categorical = do 
  rain <- unconditioned (categorical [(lit True, 0.2), (lit False, 0.8)]) 
  sprinkler <- unconditioned (if rain then bern 0.01 else bern 0.4)
  _ <- conditioned (if rain then (if sprinkler then bern 0.99 else bern 0.8)
	                else (if sprinkler then bern 0.9 else bern 0.1))
  return rain

-- printing test results
main :: IO ()
main = sample_ 3 test conds >>
       putChar '\n' >>
       sample 1000 test conds >>=
       print
  where conds = [Lebesgue (toDyn (2 :: Double))]

main_dbn :: IO ()
main_dbn = sample_ 10 test_dbn conds >>
           putChar '\n' >>
           sample 1000 test_dbn conds >>=
           print 
  where conds = [Discrete (toDyn (True :: Bool)),
                 Discrete (toDyn (True :: Bool))]

main_hmm :: IO ()
main_hmm = sample_ 10 (test_hmm 2) conds >>
           putChar '\n' >>
           sample 1000 (test_hmm 2) conds >>=
           print 
  where conds = [Discrete (toDyn (True :: Bool)),
                 Discrete (toDyn (True :: Bool))]

main_carRoadModel :: IO ()
main_carRoadModel = sample_ 10 test_carRoadModel conds >>
                    putChar '\n' >>
                    sample 1000 test_carRoadModel conds >>=
                    print 
  where conds = [Lebesgue (toDyn (0 :: Double)),
                 Lebesgue (toDyn (11 :: Double)), 
                 Lebesgue (toDyn (19 :: Double)),
                 Lebesgue (toDyn (33 :: Double))]

main_categorical :: IO ()
main_categorical = sample_ 10 test_categorical conds >>
           putChar '\n' >>
           sample 1000 test_categorical conds >>=
           print 
  where conds = [Discrete (toDyn (True :: Bool))]

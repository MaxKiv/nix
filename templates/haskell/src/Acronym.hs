module Acronym (abbreviate) where

import Data.Char

-- Return a words acronym
acronym :: String -> String
acronym xs
  | all isUpper xs = [head xs]
  | all isLower xs = [toUpper $ head xs]
  | otherwise = filter isUpper xs

abbreviate :: String -> String
abbreviate xs = concat $ map acronym $ map (filter isAlpha) $ words $ map (\c -> if c == '-' then ' ' else c) xs

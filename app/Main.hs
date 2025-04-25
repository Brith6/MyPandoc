{- 
-- EPITECH PROJECT, 2024
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- Main.hs
-}

import Config
import Engine
import System.Environment
import System.Exit
import Data.Maybe

elemCount :: Eq a => [a] -> a -> Int
elemCount [] _ = 0
elemCount ys find = length xs
    where xs = [x | x <- ys, x == find]

isValidList ::  [String] -> Maybe [String]
isValidList s
    | null s || length s < 4 || length s > 8
      || odd (length s) = Nothing
    | elemCount s "-i" /= 1 || elemCount s "-f" /= 1 ||
      elemCount s "-o" > 1 || elemCount s "-e" > 1 = Nothing
    | otherwise = Just s
    
main :: IO ()
main = do
    args <- getArgs
    if isJust (isValidList args)
    then case getOpts defaultConf args of
        Just conf -> myPandoc conf
        Nothing -> usage >> exitWith (ExitFailure 84)
    else usage >> exitWith (ExitFailure 84)
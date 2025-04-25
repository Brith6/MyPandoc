{- 
-- EPITECH PROJECT, 2024
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- Engine.hs
-}

module Engine where

import Config
import Control.Exception
import System.Exit

mySplitOn :: Char -> String -> [String]
mySplitOn _ [] = [""]
mySplitOn delimiter (x:xs)
    | x == delimiter = "" : rest
    | otherwise = (x : head rest) : tail rest
  where
    rest = mySplitOn delimiter xs

isValidFile :: String -> IO (Either IOException String)
isValidFile s = try (readFile s)

myPandoc :: Conf -> IO ()
myPandoc conf = case conf of
    (Conf (Just ifile) (Just oformat) (Just ofile) (Just iformat)) -> do
        validIFile <- isValidFile ifile
        case validIFile of
            Left _ -> usage >> exitWith (ExitFailure 84)
            Right content -> putStr "ifile: " >> putStrLn ifile >>
                             putStr "oformat: " >> putStrLn oformat >>
                             putStr "ofile: " >> putStrLn ofile >>
                             putStr "iformat: " >> putStrLn iformat
    _ -> usage >> exitWith (ExitFailure 84)


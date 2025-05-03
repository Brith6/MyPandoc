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
import TranscriptXml
import Document
import ParseXml
import Data.Char (isSpace)
import Data.List (isPrefixOf)

mySplitOn :: Char -> String -> [String]
mySplitOn _ [] = [""]
mySplitOn delimiter (x:xs)
    | x == delimiter = "" : rest
    | otherwise = (x : head rest) : tail rest
  where
    rest = mySplitOn delimiter xs

isValidFile :: String -> IO (Either IOException String)
isValidFile s = try (readFile s)

-- check for XML
isXml :: String -> Bool
isXml s = ("<?xml" `isPrefixOf` s) || (not (null s) && head s == '<')

-- check for JSON
isJson :: String -> Bool
isJson s = case s of
    ('{':_) -> True
    ('[':_) -> True
    _       -> False

-- check for Markdown
isMarkdown :: String -> Bool
isMarkdown s = ("---" `isPrefixOf` s) || ("```" `isPrefixOf` s)

-- format of a file
determineFormat :: String -> String
determineFormat content
    | isXml trimmed = "xml"
    | isJson trimmed = "json"
    | isMarkdown trimmed = "markdown"
    | otherwise = "unknown"
  where
    trimmed = dropWhile isSpace content

parseDocument:: String -> String -> Maybe Doc
parseDocument ifile iformat = case iformat of
        "xml" -> parseXmlToDoc ifile
        -- "json" -> Just $ parseJson ifile
        -- "markdown" -> Just $ parseMarkdown ifile
        "" -> parseDocument ifile (determineFormat ifile)
        _ -> Nothing

applyFormat :: Maybe Doc -> String -> String -> IO ()
applyFormat doc oformat ofile = case oformat of
        "xml" -> applyXml doc ofile
        "json" -> putStrLn "JSON format selected"
        "markdown" -> putStrLn "Markdown format selected"
        _ -> putStrLn "Unknown format"

myPandoc :: Conf -> IO ()
myPandoc conf = case conf of
    (Conf (Just ifile) (Just oformat) (Just ofile) (Just iformat)) -> do
        validIFile <- isValidFile ifile
        case validIFile of
            Left _ -> usage >> exitWith (ExitFailure 84)
            Right content -> case parseDocument content iformat of
                    Just d -> applyFormat (Just d) oformat ofile
                    Nothing -> putStrLn "Error: Invalid document format" >>
                        exitWith (ExitFailure 84)
    _ -> usage >> exitWith (ExitFailure 84)


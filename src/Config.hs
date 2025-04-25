{- 
-- EPITECH PROJECT, 2024
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- Config.hs
-}

module Config where

data Conf = Conf {
    ifile::Maybe String,
    oformat::Maybe String,
    ofile::Maybe String,
    iformat::Maybe String
} deriving (Show, Eq)

defaultConf :: Conf
defaultConf = Conf Nothing Nothing (Just "") (Just "")

getOpts :: Conf -> [String] -> Maybe Conf
getOpts conf [] = Just conf
getOpts conf (x:y:xs) =
    case x of
        "-i" -> if not (null y) then getOpts conf {ifile = Just y} xs
                else Nothing
        "-f" -> if not (null y) then getOpts conf {oformat = Just y} xs
                else Nothing
        "-o" -> getOpts conf {ofile = Just y} xs
        "-e" -> getOpts conf {iformat = Just y} xs
        _ -> Nothing

usage::IO()
usage = putStr "USAGE: ./mypandoc -i ifile -f oformat" >>
        putStrLn " [-o ofile] [-e iformat]\n" >>
        putStrLn "    ifile path to the file to convert" >>
        putStrLn "    oformat output format (xml, json, markdown)" >>
        putStrLn "    ofile path to the output file" >>
        putStrLn "    iformat input format (xml, json, markdown)"
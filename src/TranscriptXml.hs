{-
-- EPITECH PROJECT, 2024
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- TranscriptXml.hs
-}

module TranscriptXml where
import Document
import Data.Maybe (fromMaybe)
import System.Exit

-- Spaces for indentation
indent :: Int -> String
indent n = replicate n ' '

-- Convert document to XML
formatDocumentXml :: Doc -> String
formatDocumentXml doc = unlines
    [ "<document>"
    , indent 4 ++ formatHeaderXml (header doc)
    , indent 4 ++ "<body>\n" ++ formatBodyXml 8 (body doc)
        ++ indent 4 ++ "</body>"
    ] ++ "</document>"

-- Format the header
formatHeaderXml :: Header -> String
formatHeaderXml (Header title auth date) =
    "<header title=\"" ++ fromMaybe "Unknown" title ++ "\">" ++ "\n" ++
    indent 8 ++ "<author>" ++ fromMaybe "Unknown" auth ++ "</author>" ++ "\n"++
    indent 8 ++ "<date>" ++ fromMaybe "Unknown" date ++ "</date>" ++ "\n" ++
    indent 4 ++ "</header>"

-- Process a list of body elements
formatBodyXml :: Int -> [BodyElem] -> String
formatBodyXml n [] = ""
formatBodyXml n (x:xs) = formatBodyElemXml n x ++ formatBodyXml n xs

-- Process an individual body element into an XML fragment
formatBodyElemXml :: Int -> BodyElem -> String
formatBodyElemXml n BNull = ""
formatBodyElemXml n (Bdypara texts) =
    indent n ++"<paragraph>"++ concatMap formatTextXml texts ++"</paragraph>\n"
formatBodyElemXml n (Bdysection s) =
    formatSectionXml n s
formatBodyElemXml n (Bycodeblock elems) =
    indent n ++ "<codeblock>\n" ++
    formatBodyXml (n + 4) elems ++
    indent n ++ "</codeblock>\n"
formatBodyElemXml n (Bdylist opt) =
    indent n ++ "<list>\n" ++
    formatBodyXml (n + 4) (a_list opt) ++
    indent n ++ "</list>\n"

-- Format a section
formatSectionXml :: Int -> Section -> String
formatSectionXml n (Section title content) =
    indent n ++ "<section title=\"" ++ fromMaybe "Untitled" title ++ "\">\n" ++
    formatBodyXml (n + 4) content ++
    indent n ++ "</section>\n"

-- Format text values
formatTextXml :: Text -> String
formatTextXml (Text (Just "link") _ _ _ (Just txt) (Just url)) =
    "<link url=\"" ++ url ++ "\">" ++ txt ++ "</link>"
formatTextXml (Text (Just "image") _ _ _ (Just txt) (Just url)) =
    "<image url=\"" ++ url ++ "\">" ++ txt ++ "</image>"
formatTextXml (Text _ True _ _ (Just txt) _) =
    "<bold>" ++ txt ++ "</bold>"
formatTextXml (Text _ _ True _ (Just txt) _) =
    "<italic>" ++ txt ++ "</italic>"
formatTextXml (Text _ _ _ True (Just txt) _) =
    "<code>" ++ txt ++ "</code>"
formatTextXml (Text _ _ _ _ (Just txt) _) = txt
formatTextXml _ = ""


applyXml :: Maybe Doc -> String -> IO()
applyXml Nothing _ =
    putStrLn "Error: Parsing failed" >> exitWith (ExitFailure 84)
applyXml (Just doc) file =
    let xmlOutput = formatDocumentXml doc
    in if file /= "" then writeFile file xmlOutput else putStr xmlOutput
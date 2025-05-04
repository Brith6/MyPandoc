{-
-- EPITECH PROJECT, 2024
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- TranscriptMd.hs
-}

module TranscriptMd where
import Document
import Data.Maybe (fromMaybe)
import System.Exit

-- Convert document to Markdown
formatDocumentMd :: Doc -> String
formatDocumentMd doc = unlines $
      [ "---"
      , "title: " ++ fromMaybe "" title
      , "author: " ++ fromMaybe "" auth
      , "date: " ++ fromMaybe "" date
      , "---"
      , ""
      ] ++ [ formatBodyMd 1 (body doc) ]
  where
    Header title auth date = header doc

-- Process a list of body elements
formatBodyMd :: Int -> [BodyElem] -> String
formatBodyMd _ []     = ""
formatBodyMd n (x:xs) = formatBodyElemMd n x ++ formatBodyMd n xs

-- Process an individual body element into a Markdown fragment
formatBodyElemMd :: Int -> BodyElem -> String
formatBodyElemMd _ BNull = ""
formatBodyElemMd _ (Bdypara texts) =
    concatMap formatTextMd texts ++ "\n\n"
formatBodyElemMd level (Bdysection s) =
    formatSectionMd level s
formatBodyElemMd _ (Bycodeblock elems) =
    "```\n" ++ formatBodyMd 0 elems ++ "```\n"
formatBodyElemMd _ (Bdylist opt) =
    formatListMd (a_list opt) ++ "\n"

-- Format a section
formatSectionMd :: Int -> Section -> String
formatSectionMd level (Section mTitle content) = case mTitle of
    Nothing -> ""
    Just "" -> formatBodyMd (level + 1) content
    Just title -> replicate level '#' ++ " " ++ title ++ "\n\n"
                  ++ formatBodyMd (level + 1) content

-- Format inline text values
formatTextMd :: Text -> String
formatTextMd (Text (Just "link") _ _ _ (Just txt) (Just url)) =
    "[" ++ txt ++ "](" ++ url ++ ")"
formatTextMd (Text (Just "image") _ _ _ (Just txt) (Just url)) =
    " ![" ++ txt ++ "](" ++ url ++ ")"
formatTextMd (Text _ True _ _ (Just txt) _) =
    "**" ++ txt ++ "**"
formatTextMd (Text _ _ True _ (Just txt) _) =
    "*" ++ txt ++ "*"
formatTextMd (Text _ _ _ True (Just txt) _) =
    "`" ++ txt ++ "`"
formatTextMd (Text _ _ _ _ (Just txt) _) = txt
formatTextMd _ = ""

-- Format list items
formatListMd :: [BodyElem] -> String
formatListMd [] = ""
formatListMd (item:items) =
    if isBNull item then formatListMd items
    else "- " ++ extractText item ++ "\n" ++ formatListMd items

-- Helpers list
isBNull :: BodyElem -> Bool
isBNull BNull = True
isBNull _     = False

extractText :: BodyElem -> String
extractText (Bdypara texts) = concatMap formatTextMd texts
extractText _               = ""

-- Output the Markdown document.
applyMd :: Maybe Doc -> String -> IO ()
applyMd Nothing _ =
    putStrLn "Error: Parsing failed" >> exitWith (ExitFailure 84)
applyMd (Just doc) file =
    let mdOutput = formatDocumentMd doc
    in if file /= "" then writeFile file mdOutput else putStr mdOutput

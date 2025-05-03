{-
-- EPITECH PROJECT, 2025
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- JsonReader
-}

module JsonReader where
import System.IO
import Parser
import Document


readMyFile :: String -> (Maybe Doc)
readMyFile fileContent =
    let my_doc = convertJsonDoc 
            defaultDoc (runParser parseJsonObject fileContent)
        parsed = runParser parseJsonObject fileContent
    in case parsed of
        Just (JsonObject (x:xs), _) -> 
            (cvJbdy (docgiver my_doc) 
                (arraygiver (lookup "body" (x:xs))))
        _ -> Nothing

docgiver :: Maybe Doc -> Doc
docgiver (Just my_doc) = my_doc

defText :: Text
defText = Text Nothing False False False Nothing Nothing 

stringgiver :: Maybe JsonValue -> Maybe String
stringgiver my_Json = case my_Json of
                Just (JsonString s) -> Just s
                _ -> Nothing

arraygiver :: Maybe JsonValue -> Maybe [JsonValue]
arraygiver my_Json = case my_Json of
                    Just (JsonArray my_array) -> Just (my_array)
                    _ -> Nothing

-- convert the header
convertJsonDoc :: Doc -> Maybe (JsonValue, String) -> Maybe Doc
convertJsonDoc my_doc (Just ((JsonObject (x:xs)), _)) = case (x:xs) of
                ((my_string ,JsonObject (b:bs)):res) -> Just (Doc Header
                    { _headtitle = stringgiver(lookup "title" (b:bs)), 
                    author = stringgiver(lookup "author" (b:bs)),
                    date = stringgiver(lookup "date" (b:bs))} [])

cvJbdy :: Doc -> Maybe [JsonValue] -> Maybe Doc
cvJbdy my_doc (Just []) = Just my_doc
cvJbdy my_doc (Just ((JsonArray a_m):res)) =  case a_m of
            ((JsonString member):xs) -> cvJbdy (my_doc {body =
                (body my_doc) ++ [(Bdypara (cvJA
                    ((JsonString member):xs)))]}) (Just res)
            ((JsonObject (("codeblock",(JsonArray
                rsec)):[])):resObj) -> cvJbdy (my_doc {body =
                    (body my_doc) ++ [(Bycodeblock (pJcodeB 
                        rsec))]}) (Just res)
            _ -> cvJbdy my_doc (Just res)
cvJbdy my_doc (Just ((JsonObject (("codeblock",(JsonArray 
    rsec)):resObj)):res)) = cvJbdy (my_doc {body = 
        (body my_doc) ++ [(Bycodeblock (pJcodeB rsec))]}) (Just res)
cvJbdy my_doc (Just ((JsonObject (("list",(JsonArray 
    rsec)):resObj)):res)) = cvJbdy (my_doc {body = (body 
        my_doc) ++ [(Bdylist Option {a_list = (pJcodeB rsec)})]}) (Just res)
cvJbdy my_doc (Just ((JsonObject (("section",(JsonObject (("title", JsonString
    my_title):("content", JsonArray rsec):xs))):resObj)):res)) = cvJbdy 
    (my_doc {body = (body my_doc) ++ [(Bdysection Section {_sectitle =
        Just (my_title) ,content = (pJcodeB rsec)})]}) (Just res)


pJcodeB :: [JsonValue] -> [BodyElem]
pJcodeB = map ct
  where
    ct (JsonArray arr) = Bdypara (cvJA arr)
    ct (JsonObject [("codeblock", JsonArray sc)]) = Bycodeblock (pJcodeB sc)
    ct (JsonObject [("list", JsonArray sc)]) = Bdylist (Option (pJcodeB sc))
    ct (JsonObject [("section", JsonObject [("title", JsonString title), 
        ("content", JsonArray sc)])]) = 
      Bdysection (Section (Just (title)) (pJcodeB sc))
    ct x = Bdypara (cvJA [x])

cvJA :: [JsonValue] -> [Text]
cvJA = map convertText

convertText :: JsonValue -> Text
convertText (JsonString s) = defText { value = Just s }
convertText (JsonObject obj) = case obj of
    [("bold", JsonString s)]       -> defText { value = Just s, bold = True }
    [("italic", JsonString s)]     -> defText { value = Just s, italic = True }
    [("code", JsonString s)]       -> defText { value = Just s, code = True }
    [("link", JsonObject link)]    -> parseLink link
    [("image", JsonObject image)]  -> parseImage image
    _                              -> defText { value = Just "UNKNOWN_FORMAT" }

parseLink :: [(String, JsonValue)] -> Text
parseLink [("url", JsonString url), ("content", JsonArray [JsonString s])] =
    defText { encapsulator = Just "link", url = Just url, value = Just s }

parseImage :: [(String, JsonValue)] -> Text
parseImage [("url", JsonString url), ("alt", JsonArray [JsonString alt])] =
    defText { encapsulator = Just "image", url = Just url, value = Just alt }

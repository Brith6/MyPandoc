{-
-- EPITECH PROJECT, 2024
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- ParseXml.hs
-}

module ParseXml where
import Data.Maybe (fromMaybe)
import Data.List (find)
import Document
import Parser

-- Extract text content
extractText :: Xml -> Maybe String
extractText (XmlElement _ _ [XmlText txt]) = Just txt
extractText _ = Nothing

-- Parse Header
parseHeader :: Xml -> Header
parseHeader (XmlElement "header" attrs children) =
    Header 
        { _headtitle = lookup "title" attrs
        , author = getElementText "author" children
        , date = getElementText "date" children 
        }
parseHeader _ = defaultHeader

-- Parse Body Elements
parseBodyElem :: Xml -> BodyElem
parseBodyElem el@(XmlElement "paragraph" _ children) =
    Bdypara (map parseXmlText children)
parseBodyElem el@(XmlElement "list" _ children) = Bdylist (parseList el)
parseBodyElem el@(XmlElement "codeblock" _ children) =
    Bycodeblock (map parseBodyElem children)
parseBodyElem el@(XmlElement "section" _ children) =
    Bdysection (parseSection el)
parseBodyElem _ = BNull

-- Parse Paragraph
parseParagraph :: Xml -> Paragraph
parseParagraph (XmlElement "paragraph" _ children) =
    Paragraph (map parseXmlText children)
parseParagraph _ = Paragraph []

parseXmlText :: Xml -> Text
parseXmlText (XmlElement "bold" _ [XmlText val]) =
    Text Nothing True False False (Just val) Nothing
parseXmlText (XmlElement "italic" _ [XmlText val]) =
    Text Nothing False True False (Just val) Nothing
parseXmlText (XmlElement "code" _ [XmlText val]) =
    Text Nothing False False True (Just val) Nothing
parseXmlText (XmlElement "link" attrs [XmlText val]) =
    Text (Just "link") False False False (Just val) (lookup "url" attrs)
parseXmlText (XmlElement "image" attrs [XmlText val]) =
    Text (Just "image") False False False (Just val) (lookup "url" attrs)
parseXmlText (XmlText val) = Text Nothing False False False (Just val) Nothing
parseXmlText _ = Text Nothing False False False Nothing Nothing

-- Parse Sections
parseSection :: Xml -> Section
parseSection (XmlElement "section" attrs children) =
    Section (lookup "title" attrs) (map parseBodyElem children)
parseSection _ = Section Nothing []

-- Parse Lists
parseList :: Xml -> Option
parseList (XmlElement "list" _ children) = Option (map parseBodyElem children)
parseList _ = Option []

-- Construct Document
parseDocumentXml :: Xml -> Doc
parseDocumentXml (XmlElement "document" _ children) =
    let hdr = maybe defaultHeader parseHeader (findElement "header" children)
        bodyElems = case findElement "body" children of
            Just (XmlElement "body" _ bodyChildren) ->
                map parseBodyElem bodyChildren
            _ -> []
    in Doc hdr bodyElems
parseDocumentXml _ = defaultDoc

-- Convert an input string of XML into document structure
parseXmlToDoc :: String -> Maybe Doc
parseXmlToDoc input =
    case runParser parseXml input of
        Nothing -> Nothing
        Just (xmlTree, _) -> Just (parseDocumentXml xmlTree)

-- Helper Functions
isSection :: Xml -> Bool
isSection (XmlElement "section" _ _) = True
isSection _ = False

isParagraph :: Xml -> Bool
isParagraph (XmlElement "paragraph" _ _) = True
isParagraph _ = False

isCodeBlock :: Xml -> Bool
isCodeBlock (XmlElement "codeblock" _ _) = True
isCodeBlock _ = False

isList :: Xml -> Bool
isList (XmlElement "list" _ _) = True
isList _ = False

findElement :: String -> [Xml] -> Maybe Xml
findElement name =
    find (\e -> case e of XmlElement n _ _ -> n == name; _ -> False)

getElementText :: String -> [Xml] -> Maybe String
getElementText name children =
    case findElement name children of
        Just (XmlElement _ _ [XmlText txt]) -> Just txt
        _ -> Nothing

getChildren :: Xml -> [Xml]
getChildren (XmlElement _ _ children) = children
getChildren _ = []

-- Default Header
defaultHeader :: Header
defaultHeader = Header Nothing Nothing Nothing
    
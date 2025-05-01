{-
-- EPITECH PROJECT, 2025
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- Document
-}


module Document where
import Parser

data Header = Header {
    _headtitle::Maybe String,
    author::Maybe String,
    date::Maybe String
} deriving (Show)

data Paragraph = Paragraph {
    a_paragraph :: [Text]
} deriving (Show)

-- data Codeblock = Codeblock {
--     a_codeblock :: Mayb
-- } deriving (Show)

data Option = Option {
    a_list :: [BodyElem]
}deriving (Show)

data Text = Text {
    encapsulator :: Maybe String,
    bold :: Bool,
    italic:: Bool,
    code :: Bool,
    value :: Maybe String,
    url :: Maybe String
} deriving (Show)

data SectionElem = SectionElem {
    _section :: Maybe Section,
    _secpara :: Maybe Paragraph,
    _secblockcode :: Maybe String,
    _seclist :: Maybe Option
} deriving (Show)

data Section = Section {
    _sectitle :: Maybe String,
    content :: [BodyElem]
} deriving (Show)

data BodyElem = BNull
    | Bdysection Section 
    | Bdypara [Text] 
    | Bdylist Option
    | Bycodeblock [BodyElem]
    deriving (Show)

data Doc = Doc {
    header::Header,
    body::[BodyElem]
} deriving (Show)

defaultDoc :: Doc
defaultDoc = Doc (Header Nothing Nothing Nothing) []
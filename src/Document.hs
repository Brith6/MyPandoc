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
}

data Paragraph = Paragraph {
    a_paragraph :: [Text]
}

data Codeblock = Codeblock {
    a_codeblock :: [Paragraph]
}

data Option = Option {
    a_list :: [Paragraph]
}

data Text = Text {
    encapsulator :: Maybe String,
    value :: Maybe String,
    url :: Maybe String
}

data SectionElem = SectionElem {
    _section :: Maybe Section,
    _secpara :: Maybe Paragraph,
    _seccode :: Maybe Codeblock,
    _seclist :: Maybe Option
}
data Section = Section {
    _sectitle :: String,
    content :: [SectionElem]
}

data BodyElem = BodyElem {
    _bdysection :: Maybe Section,
    _bdypara :: Maybe Paragraph,
    _bdylist :: Maybe Option,
    _bdycode :: Maybe Codeblock
} 

data Doc = Doc {
    header::Header,
    body::[BodyElem]
}


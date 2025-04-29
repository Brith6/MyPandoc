import Control.Applicative
import Data.Char (isSpace)


data Parser a = Parser { runParser :: String -> Maybe (a, String) }


instance Functor Parser where
    fmap f (Parser p) = Parser $ \input ->
        case p input of
            Just (x, rest) -> Just (f x, rest)
            Nothing -> Nothing


instance Applicative Parser where
    pure x = Parser $ \input -> Just (x, input)
    (Parser pf) <*> (Parser px) = Parser $ \input ->
        case pf input of
            Just (f, rest1) ->
                case px rest1 of
                    Just (x, rest2) -> Just (f x, rest2)
                    Nothing -> Nothing
            Nothing -> Nothing

instance Alternative Parser where
    empty = Parser $ const Nothing
    (Parser p1) <|> (Parser p2) = Parser $ \input ->
        case p1 input of
            Just res -> Just res
            Nothing  -> p2 input

instance Monad Parser where
    return = pure
    (Parser p) >>= f = Parser $ \input ->
        case p input of
            Just (x, rest) -> runParser (f x) rest
            Nothing -> Nothing

parseMany :: Parser a -> Parser [a]
parseMany p = Parser $ \input ->
    case runParser p input of
        Just (x, rest) | rest /= input ->
            case runParser (parseMany p) rest of
                Just (xs, final) -> Just (x:xs, final)
                Nothing -> Just ([x], rest)
        _ -> Just ([], input)

parseString :: String -> Parser String
parseString "" = pure ""
parseString (c:cs) = (:) <$> parseChar c <*> parseString cs


data MarkdownElement
    = Title String
    | Paragraph String
    | Bold String
    | Italic String
    | ListItem String
    | CodeBlock String
    deriving (Show, Eq)

parseChar :: Char -> Parser Char
parseChar c = Parser $ \input -> case input of
    (x:xs) | x == c -> Just (x, xs)
    _ -> Nothing


parseAnyChar :: String -> Parser Char
parseAnyChar cs = Parser $ \input -> case input of
    (x:xs) | x `elem` cs -> Just (x, xs)
    _ -> Nothing


parseWhile :: (Char -> Bool) -> Parser String
parseWhile cond = Parser $ \input ->
    let (token, rest) = span cond input in Just (token, rest)


parseTitle :: Parser MarkdownElement
parseTitle = do
    _ <- parseChar '#'
    title <- parseWhile (`notElem` "\n")
    return (Title title)

parseBold :: Parser MarkdownElement
parseBold = do
    _ <- parseChar '*'
    boldText <- parseWhile (/= '*')
    _ <- parseChar '*'
    return (Bold boldText)

parseItalic :: Parser MarkdownElement
parseItalic = do
    _ <- parseChar '_'
    italicText <- parseWhile (/= '_')
    _ <- parseChar '_'
    return (Italic italicText)


parseList :: Parser MarkdownElement
parseList = do
    _ <- parseChar '*'
    _ <- parseAnyChar " \t\n"
    item <- parseWhile (/= '\n')
    return (ListItem item)


parseCodeBlock :: Parser MarkdownElement
parseCodeBlock = do
    _ <- parseString "```"
    code <- parseWhile (/= '`')
    _ <- parseString "```"
    return (CodeBlock code)


parseParagraph :: Parser MarkdownElement
parseParagraph = do
    paragraph <- parseWhile (/= '#')
    return (Paragraph paragraph)

parseMarkdown :: Parser [MarkdownElement]
parseMarkdown = parseMany (parseTitle <|> parseParagraph <|> parseList <|> parseBold <|> parseItalic <|> parseCodeBlock)


main :: IO ()
main = do
    let input = "# Title 1\nThis is a *bold* text.\n* Item 1\n* Item 2\n```haskell\nmain = putStrLn \"Hello, world!\"\n```"
    print $ runParser parseMarkdown input

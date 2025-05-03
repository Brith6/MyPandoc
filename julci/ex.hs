import Control.Applicative
import Data.Char (isSpace)
import Data.Maybe (fromMaybe)
import System.Environment (getArgs)
import Text.Read (readMaybe)
import System.Exit (exitWith, ExitCode(ExitFailure))
import Control.Exception (IOException, try)
import System.IO (readFile)
import Control.Monad (fail)

data Parser a = Parser { 
    runParser :: String -> Maybe (a, String)
}

instance Functor Parser where
    fmap f (Parser p) = Parser $ \input ->
        case p input of
            Just (x, rest) -> Just (f x, rest)
            Nothing -> Nothing

instance Applicative Parser where
    pure x = Parser $ \input -> Just (x, input)
    (Parser pf) <*> (Parser px) = Parser $ \input ->
        case pf input of
            Just (f, rest) -> case px rest of
                Just (x, rest') -> Just (f x, rest')
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

parseChar :: Char -> Parser Char
parseChar c = Parser $ \input ->
    case input of
        (x:xs) | x == c -> Just (c, xs)
        _ -> Nothing

parseAnyChar :: String -> Parser Char
parseAnyChar a = Parser $ \input ->
    case input of
        (x:xs) | x `elem` a -> Just (x, xs)
        _ -> Nothing


parseOr :: Parser a -> Parser a -> Parser a
parseOr (Parser p1) (Parser p2) = Parser $ \xs ->
            case p1 xs of
                Just res -> Just res
                Nothing -> p2 xs

parseAnd :: Parser a -> Parser b -> Parser (a, b)
parseAnd (Parser p1) (Parser p2) = Parser $ \(x:xs) ->
            case (p1 (x:xs), p2 xs) of
                (Just (e, f), Just (g, h)) -> Just ((e, g), h)
                _ -> Nothing

parseAndWith :: (a -> b -> c) -> Parser a -> Parser b -> Parser c
parseAndWith f p1 p2 = Parser $ \input ->
    case runParser (parseAnd p1 p2) input of
        Just ((i, j), k) -> Just (f i j, k)
        Nothing -> Nothing

parseMany :: Parser a -> Parser [a]
parseMany p = Parser $ \input ->
    case runParser p input of
        Just (x, rest) | rest /= input ->
            case runParser (parseMany p) rest of
                Just (xs, final) -> Just (x:xs, final)
                Nothing -> Just ([x], rest)
        _ -> Just ([], input)


parseSome :: Parser a -> Parser [a]
parseSome (Parser a1) = Parser $ \input ->
    case input of
        [] -> Nothing
        (x:xs) -> case (a1 (x:xs)) of
            Just (e, f) -> case runParser (parseSome (Parser a1)) f of
                Just (es, res) -> Just (e : es, res)
                Nothing -> Just ([e], f)
            Nothing -> Nothing

parseUInt :: Parser Int
parseUInt = do
    digits <- parseSome (parseAnyChar ['0'..'9'])
    return (read digits)

parseInt :: Parser Int
parseInt = do
        digits <- parseSome (parseAnyChar (['-'] ++ ['0'..'9']))
        return (read digits)

parseSpaces :: Parser String
parseSpaces = parseMany (parseAnyChar " \t\n\r")

parseString :: String -> Parser String
parseString "" = pure ""
parseString (c:cs) = (:) <$> parseChar c <*> parseString cs

data Xml
    = XmlElement String [(String, String)] [Xml]  -- nom, attributs, contenu
    | XmlText String
    deriving (Show, Eq)


parseWhile :: (Char -> Bool) -> Parser String
parseWhile cond = Parser $ \input ->
    let (token, rest) = span cond input
    in Just (token, rest)

parseIdentifier :: Parser String
parseIdentifier = (:) <$> parseAnyChar (['a'..'z'] ++ ['A'..'Z']) <*> parseMany (parseAnyChar identChars)
  where
    identChars = ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9'] ++ "-_:."


parseText :: Parser Xml
parseText = Parser $ \input ->
    case parseWhile (`notElem` "<") `runParser` input of
        Just (txt, rest) ->
            if null txt
                then Nothing
                else Just (XmlText txt, rest)
        Nothing -> Nothing



parseAttr :: Parser (String, String)
parseAttr = do
    _ <- parseSpaces
    key <- parseIdentifier
    _ <- parseSpaces
    _ <- parseChar '='
    _ <- parseSpaces
    _ <- parseChar '"'
    val <- parseWhile (/= '"')
    _ <- parseChar '"'
    return (key, val)

parseAttrs :: Parser [(String, String)]
parseAttrs = parseMany parseAttr

parseXmlElement :: Parser Xml
parseXmlElement = do
    _ <- parseChar '<'
    name <- parseIdentifier
    attrs <- parseAttrs
    _ <- parseSpaces
    selfClose <- (parseString "/>" *> pure True) <|> (parseChar '>' *> pure False)

    if selfClose
        then return $ XmlElement name attrs []
        else do
            children <- parseMany parseXmlContent
            _ <- parseString "</"
            _ <- parseIdentifier 
            _ <- parseChar '>'
            return $ XmlElement name attrs children

parseXmlContent :: Parser Xml
parseXmlContent = parseXmlElement <|> parseText


parseXml :: Parser Xml
parseXml = parseSpaces *> parseXmlElement <* parseSpaces

{--main :: IO ()
main = do
    
    print $ runParser parseXml input
    --}

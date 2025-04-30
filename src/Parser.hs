{-
-- EPITECH PROJECT, 2025
-- Piscine
-- File description:
-- pandoc
-}
module Parser where
import Data.List (intercalate)
import Data.Maybe (fromMaybe)
import Data.Traversable (traverse)
import Control.Applicative
import Control.Monad (fail)
import Text.Read

-- step 1 & 2

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
parseAnyChar a = Parser $ \(x:xs) ->
            if elem x a then Just (x, xs) else Nothing

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
parseMany (Parser a1) = Parser $ \input ->
    case a1 input of
        Just (e, rest) -> case runParser (parseMany (Parser a1)) rest of
            Just (es, res) -> Just (e : es, res)
            Nothing -> Just ([e], rest)
        Nothing -> Just ([], input)

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

-- step3

data JsonValue
    = JsonNull
    | JsonBool Bool
    | JsonNumber Double
    | JsonString String
    | JsonArray [JsonValue]
    | JsonObject [(String, JsonValue)]
    deriving (Show, Eq)

parseJsonValue :: Parser JsonValue
parseJsonValue = 
    parseJsonNull    <|>
    parseJsonBool    <|>
    parseJsonNumber  <|>
    parseJsonString  <|>
    parseJsonArray   <|>
    parseJsonObject

instance MonadFail Parser where
    fail _ = Parser $ const Nothing

string :: String -> Parser String
string [] = pure []
string (c:cs) = (:) <$> parseChar c <*> string cs

parseSpaces :: Parser String
parseSpaces = parseMany (parseAnyChar " \t\n\r")

-- pour "null"
parseJsonNull :: Parser JsonValue
parseJsonNull = string "null" *> pure JsonNull

-- pour "true" ou "false"
parseJsonBool :: Parser JsonValue
parseJsonBool = 
    (string "true" *> pure (JsonBool True)) <|>
    (string "false" *> pure (JsonBool False))

-- pour un chiffre
parseDigit :: Parser Char
parseDigit = parseAnyChar ['0'..'9']

-- pour un entier non signé
parseUnsignedInt :: Parser String
parseUnsignedInt = parseSome parseDigit

-- pour les signes
parseSign :: Parser (Maybe Char)
parseSign = optional (parseAnyChar "-")

-- pour la partie décimale
parseDecimal :: Parser (Maybe String)
parseDecimal = optional (parseChar '.' *> parseUnsignedInt)

-- ce qu'on veut finally pour un nombre
parseJsonNumber :: Parser JsonValue
parseJsonNumber = do
    sign <- parseSign
    val <- parseUnsignedInt
    val' <- parseDecimal
    let num = (maybe "" (:[]) sign) ++ val ++ (maybe "" ("." ++) val')
    case readMaybe num of
        Just n -> pure (JsonNumber n)
        Nothing -> fail "Invalid number format"

-- pour une string
parseJsonString :: Parser JsonValue
parseJsonString = JsonString <$> (parseChar '"' *> parseStr <* parseChar '"')
  where
    parseStr = Parser $ \input ->
        let (content, rest) = span (/= '"') input
        in Just (content, rest)

-- pour un tableau
parseJsonArray :: Parser JsonValue
parseJsonArray = do
    _ <- parseChar '['
    parseSpaces
    values <- parseArr <|> return []
    parseSpaces
    _ <- parseChar ']'
    return (JsonArray values)
  where
    parseArr = do
        first <- parseJsonValue
        parseSpaces
        rest <- parseMany (parseChar ',' *> parseSpaces *> parseJsonValue <* parseSpaces)
        return (first : rest)

-- pour un objet
parseJsonObject :: Parser JsonValue
parseJsonObject = do
    _ <- parseChar '{'
    parseSpaces
    pairs <- parseVal <|> pure []
    parseSpaces
    _ <- parseChar '}'
    return (JsonObject pairs)
  where
    parseVal = do
        pair <- parsePair
        _ <- parseSpaces
        rest <- parseMany (parseChar ',' *> parseSpaces *> parsePair <* parseSpaces)
        return (pair : rest)    
    parsePair = do
        JsonString key <- parseJsonString
        parseSpaces
        _ <- parseChar ':'
        parseSpaces
        value <- parseJsonValue
        return (key, value)

-- step4
printJson :: JsonValue -> String
printJson JsonNull = "null"
printJson (JsonBool True) = "true"
printJson (JsonBool False) = "false"
printJson (JsonNumber n) = show n
printJson (JsonString s) = show s
printJson (JsonArray xs) = "[" ++ intercalate "," (map printJson xs) ++ "]"
printJson (JsonObject ax) = "{" ++ intercalate "," (map printPair ax) ++ "}"
    where
        printPair (k, v) = show k ++ ":" ++ printJson v

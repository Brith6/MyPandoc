{-
-- EPITECH PROJECT, 2025
-- Piscine
-- File description:
-- pandoc
-}

{-|

Module      : Parser
Description : Un parseur combinatoire simple pour JSON et XML
Auteurs  : julcinia.oke@epitech.eu, bill.adjagboni@epitech.eu

Ce module définit un mini-framework de parsing basé sur le type 'Parser', avec
des implémentations concrètes pour la lecture de valeurs JSON et XML.
-}

module Parser where
import Control.Applicative
import Data.List (intercalate)
import Text.Read

--------------------------------------------------------------------------------
-- | Type de parseur générique.
--
-- Un parseur prend une 'String' en entrée et retourne potentiellement
-- une valeur de type @a@ accompagnée du reste de l'entrée non consommée.

data Parser a = Parser { 
    runParser :: String -> Maybe (a, String)
}


--------------------------------------------------------------------------------
-- * Instances de typeclass pour `Parser`

-- | 'fmap' permet d'appliquer une fonction à la sortie d’un parseur.

instance Functor Parser where
    fmap f (Parser p) = Parser $ \input ->
        case p input of
            Just (x, rest) -> Just (f x, rest)
            Nothing -> Nothing



-- | Permet la composition séquentielle de parseurs.


instance Applicative Parser where
    pure x = Parser $ \input -> Just (x, input)

    (Parser pf) <*> (Parser px) = Parser $ \input ->
        case pf input of
            Just (f, rest) -> case px rest of
                Just (x, rest') -> Just (f x, rest')
                Nothing -> Nothing
            Nothing -> Nothing


-- | Permet la composition séquentielle de parseurs.

instance Alternative Parser where
    empty = Parser $ const Nothing

    (Parser p1) <|> (Parser p2) = Parser $ \input ->
        case p1 input of
            Just res -> Just res
            Nothing  -> p2 input


-- | Permet d'enchaîner les parseurs de façon monadique.

instance Monad Parser where
    return = pure

    (Parser p) >>= f = Parser $ \input ->
        case p input of
            Just (x, rest) -> runParser (f x) rest
            Nothing -> Nothing




-- | Parse un caractère parmi ceux spécifiés.
--parseAnyChar :: String -> Parser Char

-- | Essaye un parseur, puis un autre si le premier échoue.
--parseOr :: Parser a -> Parser a -> Parser a

-- | Applique deux parseurs séquentiellement et retourne un couple.
--parseAnd :: Parser a -> Parser b -> Parser (a, b)

-- | Applique deux parseurs et combine leurs résultats avec une fonction.
--parseAndWith :: (a -> b -> c) -> Parser a -> Parser b -> Parser c

-- | Applique un parseur autant de fois que possible (zéro ou plus).
--parseMany :: Parser a -> Parser [a]

-- | Applique un parseur une ou plusieurs fois.
--parseSome :: Parser a -> Parser [a]

--------------------------------------------------------------------------------
-- * Parseurs numériques

-- | Parse un entier non signé.
--parseUInt :: Parser Int

-- | Parse un entier signé.
--parseInt :: Parser Int

charr :: Char -> Parser Char
charr c = Parser $ \input ->
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




--------------------------------------------------------------------------------
-- * Type JSON

-- | Représentation d’une valeur JSON.
data JsonValue
    = JsonNull
    | JsonBool Bool
    | JsonNumber Double
    | JsonString String
    | JsonArray [JsonValue]
    | JsonObject [(String, JsonValue)]
    deriving (Show, Eq)

-- | Parse une valeur JSON générique.
--parseJsonValue :: Parser JsonValue

-- | Parse la valeur JSON @null@.
--parseJsonNull :: Parser JsonValue

-- | Parse un booléen JSON : @true@ ou @false@.
--parseJsonBool :: Parser JsonValue

-- | Parse un nombre JSON.
--parseJsonNumber :: Parser JsonValue

-- | Parse une chaîne JSON entourée de guillemets.
--parseJsonString :: Parser JsonValue

-- | Parse un tableau JSON.
--parseJsonArray :: Parser JsonValue

-- | Parse une liste de valeurs JSON dans un tableau.
--parseArr :: Parser [JsonValue]

-- | Parse un objet JSON.
--parseJsonObject :: Parser JsonValue

-- | Parse une liste de paires clé/valeur pour un objet JSON.
--parseVal :: Parser [(String, JsonValue)]

-- | Parse une paire clé/valeur d'un objet JSON.
--parsePair :: Parser (String, JsonValue)

-- | Affiche une valeur JSON sous forme de chaîne valide JSON.
--printJson :: JsonValue -> String

--------------------------------------------------------------------------------
-- * Parseurs utilitaires

-- | Parse une chaîne littérale.
--string :: String -> Parser String

-- | Parse un ou plusieurs caractères d'espacement.
--space :: Parser String

-- | Parse un chiffre.
--parseDigit :: Parser Char

-- | Parse une séquence de chiffres.
--parseUnsignedInt :: Parser String

-- | Parse un signe optionnel.
--parseSign :: Parser (Maybe Char)

-- | Parse une partie décimale optionnelle.
--parseDecimal :: Parser (Maybe String)

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
string (c:cs) = (:) <$> charr c <*> string cs

space :: Parser String
space = parseMany (parseAnyChar " \t\n\r")

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
parseDecimal = optional (charr '.' *> parseUnsignedInt)

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
parseJsonString = JsonString <$> (charr '"' *> parseStr <* charr '"')
  where
    parseStr = Parser $ \input ->
        let (content, rest) = span (/= '"') input
        in Just (content, rest)

-- pour un tableau
parseJsonArray :: Parser JsonValue
parseJsonArray = do
    _ <- charr '['
    space
    values <- parseArr <|> return []
    space
    _ <- charr ']'
    return (JsonArray values)

parseArr :: Parser [JsonValue]
parseArr = do
    first <- parseJsonValue
    space
    rest <- parseMany (charr ',' *> space *> parseJsonValue <* space)
    return (first : rest)

-- pour un objet
parseJsonObject :: Parser JsonValue
parseJsonObject = do
    _ <- charr '{'
    space
    pairs <- parseVal <|> pure []
    space
    _ <- charr '}'
    return (JsonObject pairs)

parseVal :: Parser [(String, JsonValue)]
parseVal = do
    pair <- parsePair
    _ <- space
    rest <- parseMany (charr ',' *> space *> parsePair <* space)
    return (pair : rest)

parsePair :: Parser (String, JsonValue)
parsePair = do
    JsonString key <- parseJsonString
    space
    _ <- charr ':'
    space
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


-- Paser Xml



--------------------------------------------------------------------------------
-- * XML

-- | Représente un nœud XML.


data Xml
    = XmlElement String [(String, String)] [Xml]  -- nom, attributs, contenu
    | XmlText String
    deriving (Show, Eq)


-- | Parse une chaîne tant qu'une condition est vraie.

parseWhile :: (Char -> Bool) -> Parser String
parseWhile cond = Parser $ \input ->
    let (token, rest) = span cond input
    in Just (token, rest)


-- | Parse un identifiant XML (nom de balise ou attribut).

parseIdentifier :: Parser String
parseIdentifier = (:) <$> parseAnyChar (['a'..'z'] ++ ['A'..'Z'])
    <*> parseMany (parseAnyChar identChars)
  where
    identChars = ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9'] ++ "-_:."



-- | Parse du texte brut XML (non-balise).

parseText :: Parser Xml
parseText = Parser $ \input ->
    case parseWhile (`notElem` "<") `runParser` input of
        Just (txt, rest) ->
            if null txt
                then Nothing
                else Just (XmlText txt, rest)
        Nothing -> Nothing

-- | Parse une paire attribut/valeur.

parseAttr :: Parser (String, String)
parseAttr = do
    _ <- space
    key <- parseIdentifier
    _ <- space
    _ <- charr '='
    _ <- space
    _ <- charr '"'
    val <- parseWhile (/= '"')
    _ <- charr '"'
    return (key, val)


-- | Parse plusieurs attributs XML.

parseAttrs :: Parser [(String, String)]
parseAttrs = parseMany parseAttr


-- | Parse une balise ouvrante avec attributs.

parseXmlStartTag :: Parser (String, [(String, String)], Bool)
parseXmlStartTag = do
    _ <- charr '<'
    name <- parseIdentifier
    attrs <- parseAttrs
    _ <- space
    baliseIsClose <- (string "/>" *> pure True) <|> (charr '>' *> pure False)
    return (name, attrs, baliseIsClose)

-- | Parse un élément XML complet.

parseXmlElement :: Parser Xml
parseXmlElement = do
    (name, attrs, baliseIsClose) <- parseXmlStartTag
    if baliseIsClose
        then return $ XmlElement name attrs []
        else do
            children <- parseMany parseXmlContent
            _ <- string "</"
            _ <- parseIdentifier
            _ <- charr '>'
            return $ XmlElement name attrs children


-- | Parse le contenu interne d’un élément XML (texte ou enfants).

parseXmlContent :: Parser Xml
parseXmlContent = parseXmlElement <|> parseText

-- | Point d’entrée pour parser un document XML.

parseXml :: Parser Xml
parseXml = space *> parseXmlElement <* space

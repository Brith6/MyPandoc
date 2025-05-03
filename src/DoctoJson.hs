{-
-- EPITECH PROJECT, 2025
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- DoctoJson
-}

module DoctoJson where
import JsonReader
import Document
import Data.List
import System.Exit

my_author_add :: Maybe String -> String
my_author_add Nothing = ""
my_author_add (Just auth) = ",\n        \"author\": \"" ++ auth ++ "\""

date_add :: Maybe String -> String
date_add Nothing = ""
date_add (Just dt) = ",\n        \"date\": \"" ++ dt ++ "\""

str_taker :: Maybe String -> String
str_taker Nothing = ""
str_taker (Just (s)) = s

header_Writer :: Header -> String
header_Writer (Header t a d) =
  (tab_giver 1) ++ "\"header\": {\n" ++
  "        \"title\": \"" ++ (str_taker t) ++ "\"" ++
  my_author_add a ++
  date_add d ++
  "\n    }"

s_object_adder :: String -> String -> String -> Int -> String
s_object_adder "link" value url num = (tab_giver (num)) ++ "{\n" ++ (tab_giver
 (num + 1)) ++ "\"" ++ "link" ++ "\": " ++ "{\n"++
    (object_adder "url" url (num + 1)) ++ ",\n" ++ (tab_giver (num + 1)) ++ 
    "\"alt\": [\n" ++ (tab_giver(num +2)) ++ "\"" ++ value  ++ "\"" ++ "\n"
    ++ (tab_giver(num +1))  ++ "]\n" ++ tab_giver(num) ++ "}"
s_object_adder "image" value url num = (tab_giver (num)) ++ "{\n" ++ 
    (tab_giver (num + 1)) ++ "\"" ++ "image" ++ "\": " ++ "{\n"++
    (object_adder "url" url (num + 1)) ++ ",\n" ++ (tab_giver
    (num + 1)) ++ "\"alt\": [\n" ++ (tab_giver(num +2)) ++ "\""
    ++ value  ++ "\"" ++ "\n" ++ (tab_giver(num +1))  ++ "]\n" 
    ++ tab_giver(num) ++ "}"

openner :: Int -> String
openner num = "\n" ++ (tab_giver (num)) ++ "{\n"


ender :: Int -> String
ender num = "\n" ++ (tab_giver (num)) ++ "}"


object_adder :: String -> String -> Int -> String
object_adder format value num = (tab_giver (num)) ++ "\"" 
    ++ format ++ "\": " ++ "\""++ value ++ "\"" 

text_writer :: Text -> Int -> String
text_writer (Text Nothing False False False (Just(value)) Nothing) num = "\n"
    ++ tab_giver (num + 1) ++  "\"" ++ value ++ "\""
text_writer (Text Nothing False False True (Just(value)) Nothing) num = ((
    openner(num + 1)) ++(object_adder "code" value (num + 2)) ++ 
    (ender(num + 1)))
text_writer (Text Nothing False True False (Just(value)) Nothing) num = ((
    openner(num + 1)) ++(object_adder "italic" 
    value (num + 2)) ++ (ender(num + 1)))
text_writer (Text Nothing True False False (Just(value)) Nothing) num = ((
    openner(num + 1)) ++(object_adder "bold" value (num + 2)) 
    ++ (ender(num + 1)))
text_writer (Text (Just ("link")) False False False (Just(v)) (Just(u))) num = 
    ((tab_giver (num+1))  
    ++ "\n") ++(s_object_adder "link" v u (num + 1))
text_writer (Text (Just ("image")) False False False (Just(v)) (Just(u))) num =
    ((tab_giver (num+1))  
    ++ "\n") ++(s_object_adder "image" v u (num + 1))
text_writer _ _ = ""
paragraph_writer :: BodyElem -> Int -> String
paragraph_writer (Bdypara texts) num =
  tab_giver (num) ++ "[" ++ tab_giver (num + 2) ++ 
  intercalate "," (map (\t -> text_writer t num) texts) ++
   "\n" ++ tab_giver (num) ++ "]"

retrieve_text :: [BodyElem] -> Text
retrieve_text ((Bdypara (x:xs)):res) = x

codeblock_writer :: [BodyElem] -> Int -> String
codeblock_writer lines num =
  tab_giver num ++ "{\n" ++ tab_giver (num + 1) ++ "\"codeblock\": [" ++
   tab_giver (num + 2)
   ++ (text_writer (retrieve_text lines) (num + 1))  ++ "\n" ++
  tab_giver (num + 1) ++ "]\n" ++ (tab_giver (num)) ++ "}"

list_writer :: BodyElem -> Int -> String
list_writer (Bdylist (Option a_list)) num =
  tab_giver num ++ "{\n" ++ tab_giver (num + 1) ++ "\"list\": [\n" ++
  intercalate ",\n" (map (listItem_writer (num + 1)) a_list) ++ "\n" ++
  tab_giver (num + 1) ++ "]\n" ++ tab_giver num ++ "}"

listItem_writer :: Int -> BodyElem -> String
listItem_writer num (Bdypara p) = paragraph_writer (Bdypara p) (num+1)
listItem_writer num (Bdylist l) = list_writer (Bdylist l) (num+1)

section_writer :: Section -> Int -> String
section_writer (Section title content) num =
  tab_giver num ++ "{\n"++ tab_giver (num + 1) ++ "\"section\": {\n" ++
  tab_giver (num+2) ++ "\"title\": \"" ++ (str_taker title) ++ "\",\n" ++
  tab_giver (num+2) ++ "\"content\": [\n" ++ 
  intercalate ",\n" (map (bodyElem_writer (num + 3)) content) ++ "\n" ++
  tab_giver (num+2) ++ "]\n" ++
  tab_giver (num + 1) ++ "}\n" ++ tab_giver (num) ++ "}"

bodyElem_writer :: Int -> BodyElem -> String
bodyElem_writer num (Bdypara p) = paragraph_writer (Bdypara p) num
bodyElem_writer  num (Bdysection s) = section_writer s num
bodyElem_writer num (Bycodeblock c) = codeblock_writer (nullfilter c) num
bodyElem_writer num (Bdylist l)= list_writer (Bdylist l) num

tab_giver :: Int -> String
tab_giver num = replicate (num * 4) ' '

docToJson :: Doc -> String
docToJson (Doc header body) =
  "{\n" ++
  header_Writer header ++ ",\n" ++
  "    \"body\": [\n" ++ 
  intercalate ",\n" (map (\e -> bodyElem_writer 2 e)
  (nullfilter body)) ++ "\n" ++
  (tab_giver 1) ++ "]" ++ "\n}"

nullfilter :: [BodyElem] -> [BodyElem]
nullfilter [] = []
nullfilter (BNull : xs) = nullfilter xs
nullfilter (Bdypara texts : xs) = Bdypara texts : nullfilter xs
nullfilter (Bdysection (Section title content) : xs) = 
    Bdysection (Section title (nullfilter content)) : nullfilter xs
nullfilter (Bycodeblock blocks : xs) = 
    Bycodeblock (nullfilter blocks) : nullfilter xs
nullfilter (Bdylist (Option items) : xs) = 
    Bdylist (Option (nullfilter items)) : nullfilter xs
nullfilter (x:xs) = x : nullfilter xs  -- Cas par défaut au cas où

docTaker:: Maybe Doc -> Doc
docTaker (Just my_doc) =my_doc
docTaker Nothing = defaultDoc

-- printDocumentJson :: Doc -> IO ()
-- printDocumentJson = putStrLn . docToJson

applyJson :: Maybe Doc -> String -> IO()
applyJson Nothing _ =
    putStrLn "Error: Parsing failed" >> exitWith (ExitFailure 84)
applyJson (Just doc) file = if file /= "" 
                        then writeFile file (docToJson doc) 
                        else putStr (docToJson doc)

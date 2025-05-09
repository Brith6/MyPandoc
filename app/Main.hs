{- 
-- EPITECH PROJECT, 2024
-- B-FUN-400-COT-4-1-mypandoc-julcinia.oke
-- File description:
-- Main.hs
-}

import Config
import Engine
import System.Environment
import System.Exit
import Data.Maybe

-- | Compte le nombre d’occurrences d’un élément donné dans une liste.
--
-- >>> elemCount [1, 2, 3, 2, 2] 2
-- 3

elemCount :: Eq a => [a] -> a -> Int
elemCount [] _ = 0
elemCount ys find = length xs
    where xs = [x | x <- ys, x == find]

isValidList ::  [String] -> Maybe [String]
isValidList s
    | null s || length s < 4 || length s > 8
      || odd (length s) = Nothing
    | elemCount s "-i" /= 1 || elemCount s "-f" /= 1 ||
      elemCount s "-o" > 1 || elemCount s "-e" > 1 = Nothing
    | otherwise = Just s
    
-- | Vérifie si la liste d’arguments est valide selon des règles précises :
--
-- * La liste ne doit pas être vide.
-- * Elle doit contenir entre 4 et 8 éléments.
-- * Le nombre d'éléments doit être pair.
-- * Elle doit contenir exactement un "-i" et un "-f".
-- * Elle peut contenir au plus un "-o" et un "-e".
--
-- Retourne 'Just' la liste si elle est valide, sinon 'Nothing'.
--
-- >>> isValidList ["-i", "input.md", "-f", "html"]
-- Just ["-i","input.md","-f","html"]

-- | Point d’entrée principal du programme.
--
-- Lit les arguments de la ligne de commande, les valide,
-- puis configure et exécute 'myPandoc'. En cas d'erreur, affiche l'usage
-- et retourne un code de sortie 84.

main :: IO ()
main = do
    args <- getArgs
    if isJust (isValidList args)
    then case getOpts defaultConf args of
        Just conf -> myPandoc conf
        Nothing -> usage >> exitWith (ExitFailure 84)
    else usage >> exitWith (ExitFailure 84)



    
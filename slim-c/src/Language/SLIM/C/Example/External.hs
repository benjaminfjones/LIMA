{- |
Module: External
Description: Example of referencing external variables and functions in SLIM
Copyright: (c) 2015 Chris Hodapp

This demonstrates the use of 'word16'' to reference an external variable, and
the use of 'call' to call an external function.

-}
module Language.SLIM.C.Example.External where

import Language.SLIM
import Language.SLIM.C

-- | Invoke the SLIM compiler
main :: IO ()
main = do
  let atomCfg = defaults { cCode = prePostCode , cRuleCoverage = False }
  r <- compile "extern_example" atomCfg extern
  putStrLn $ reportSchedule (compSchedule r)

-- | Top-level rule
extern :: Atom ()
extern = do

  -- External reference to a variable 'g_random' which is a uint16:
  let rng = word16' "g_random"

  atom "update" $ do
    -- Call external function 'new_random' which updates g_random:
    call "new_random"
    printIntegralE "g_random" $ value rng

prePostCode :: [Name] -> [Name] -> [(Name, Type)] -> (String, String)
prePostCode _ _ _ =
  ( unlines [ "// ---- This source is automatically generated by SLIM ----"
            , "#include <stdio.h>"
            , "#include <stdlib.h>"
            , "#include <unistd.h>"
            , ""
              -- Declarations of what we reference above:
            , "static uint16_t g_random = 0;"
            , "void new_random(void);"
            ]
  , unlines [ "int main(void) {"
            , "    while (true) {"
            , "        extern_example();"
            , "        usleep(1000);"
            , "    }"
            , "    return 0;"
            , "}"
            , ""
              -- And the function definition:
            , "void new_random(void) {"
            , "    g_random = rand();"
            , "}"
            , "// ---- End automatically-generated source ----"
            ])

import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";
import { defineConfig, globalIgnores } from "eslint/config";

export default defineConfig([
  globalIgnores(["**/dist/**", "**/node_modules/**"]),
  {
    files: ["apps/web/**/*.{js,ts,jsx,tsx}"],
    plugins: { js },
    extends: ["js/recommended"],
    languageOptions: {
      globals: globals.browser,
      parserOptions: {
        tsconfigRootDir: __dirname,
      },
    },
  },
  {
    files: ["apps/{api-gateway,flight,document}/**/*.{js,mjs,cjs,ts,mts,cts}"],
    plugins: { js },
    extends: ["js/recommended"],
    languageOptions: {
      globals: globals.node,
      parserOptions: {
        tsconfigRootDir: __dirname,
      },
    },
  },
  tseslint.configs.recommended,
  {
    rules: {
      "@typescript-eslint/no-namespace": [
        "error",
        {
          allowDeclarations: true,
        },
      ],
    },
  },
]);

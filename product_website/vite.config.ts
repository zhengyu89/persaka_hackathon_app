import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "node:path";

// GitHub Pages serves this project from https://<username>.github.io/persaka_hackathon_app/
// so the production base path must match the repository name.
// Override with VITE_BASE if the repository is renamed.
const base = process.env.VITE_BASE ?? "/persaka_hackathon_app/";

export default defineConfig(({ command }) => ({
  base: command === "build" ? base : "/",
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "src"),
    },
  },
  build: {
    outDir: "dist",
    assetsInlineLimit: 4096,
  },
}));

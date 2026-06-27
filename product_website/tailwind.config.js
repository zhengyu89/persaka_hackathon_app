/** @type {import('tailwindcss').Config} */
export default {
  darkMode: "class",
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        persaka: {
          red: "#FF001F",
          purple: "#4B0082",
          accent: "#6A0DAD",
        },
        ink: "#1A1A1A",
        muted: "#666666",
        surface: "#FFFFFF",
        canvas: "#F8F8FB",
      },
      fontFamily: {
        heading: ["Poppins", "ui-sans-serif", "system-ui", "sans-serif"],
        body: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
      },
      borderRadius: {
        xl: "1rem",
        "2xl": "1.25rem",
      },
      boxShadow: {
        soft: "0 10px 30px -12px rgba(75, 0, 130, 0.18)",
        card: "0 4px 24px -8px rgba(26, 26, 26, 0.12)",
      },
      backgroundImage: {
        "persaka-gradient":
          "linear-gradient(135deg, #FF001F 0%, #6A0DAD 55%, #4B0082 100%)",
      },
      keyframes: {
        "fade-up": {
          "0%": { opacity: "0", transform: "translateY(16px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        spotlight: {
          "0%": { opacity: "0", transform: "translate(-72%, -62%) scale(0.5)" },
          "100%": {
            opacity: "1",
            transform: "translate(-50%,-40%) scale(1)",
          },
        },
        marquee: {
          "0%": { transform: "translateX(0)" },
          "100%": { transform: "translateX(-50%)" },
        },
      },
      animation: {
        "fade-up": "fade-up 0.6s ease-out both",
        spotlight: "spotlight 2s ease 0.75s 1 forwards",
        marquee: "marquee 30s linear infinite",
      },
    },
  },
  plugins: [],
};

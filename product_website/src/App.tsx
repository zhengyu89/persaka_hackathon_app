import { Navbar } from "./components/layout/Navbar";
import { Footer } from "./components/layout/Footer";
import { Hero } from "./components/sections/Hero";
import { ProblemSolution } from "./components/sections/ProblemSolution";
import { Features } from "./components/sections/Features";
import { Screenshots } from "./components/sections/Screenshots";
import { Benefits } from "./components/sections/Benefits";
import { About } from "./components/sections/About";
import { Team } from "./components/sections/Team";
import { Contact } from "./components/sections/Contact";

export default function App() {
  return (
    <>
      {/* Skip link for keyboard and screen-reader users. */}
      <a
        href="#home"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[100] focus:rounded-lg focus:bg-persaka-purple focus:px-4 focus:py-2 focus:text-white"
      >
        Skip to main content
      </a>
      <Navbar />
      <main id="home">
        <Hero />
        <ProblemSolution />
        <Features />
        <Screenshots />
        <Benefits />
        <About />
        <Team />
        <Contact />
      </main>
      <Footer />
    </>
  );
}

import { motion, useReducedMotion } from "motion/react";
import { ArrowRight, Images, Smartphone } from "lucide-react";
import { Spotlight } from "@/components/ui/spotlight";
import { product } from "@/data/site";
import { scrollToSection } from "@/lib/utils";

export function Hero() {
  const reduce = useReducedMotion();

  return (
    <section
      aria-labelledby="hero-heading"
      className="relative overflow-hidden bg-canvas pt-28 sm:pt-32 lg:pt-36"
    >
      {/* Subtle grid background (decorative). */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 bg-[linear-gradient(to_right,rgba(75,0,130,0.05)_1px,transparent_1px),linear-gradient(to_bottom,rgba(75,0,130,0.05)_1px,transparent_1px)] bg-[size:42px_42px] [mask-image:radial-gradient(ellipse_70%_60%_at_50%_0%,#000_60%,transparent_100%)]"
      />
      <Spotlight className="-top-40 left-0 md:-top-20 md:left-60" />

      <div className="container-page relative z-10 grid items-center gap-12 pb-20 lg:grid-cols-2 lg:gap-8 lg:pb-28">
        <div className="text-center lg:text-left">
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="eyebrow"
          >
            <img
              src={product.logo}
              alt=""
              className="h-4 w-4 rounded-full object-contain"
            />
            Hackathon management, simplified
          </motion.span>

          <motion.h1
            id="hero-heading"
            initial={reduce ? false : { opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.05 }}
            className="mt-5 text-4xl font-extrabold leading-[1.1] tracking-tight text-ink sm:text-5xl lg:text-6xl"
          >
            {product.name.split(" ").slice(0, -1).join(" ")}{" "}
            <span className="bg-persaka-gradient bg-clip-text text-transparent">
              {product.name.split(" ").slice(-1)}
            </span>
          </motion.h1>

          <motion.p
            initial={reduce ? false : { opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="mx-auto mt-4 max-w-xl text-lg font-medium text-ink/80 lg:mx-0"
          >
            {product.tagline}
          </motion.p>

          <motion.p
            initial={reduce ? false : { opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.15 }}
            className="mx-auto mt-4 max-w-xl text-base leading-relaxed text-muted lg:mx-0"
          >
            {product.valueProposition}
          </motion.p>

          <motion.div
            initial={reduce ? false : { opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="mt-8 flex flex-col items-center gap-3 sm:flex-row lg:justify-start"
          >
            <button
              type="button"
              onClick={() => scrollToSection("features")}
              className="btn-primary w-full sm:w-auto"
            >
              Explore features
              <ArrowRight className="h-4 w-4" aria-hidden="true" />
            </button>
            <button
              type="button"
              onClick={() => scrollToSection("screenshots")}
              className="btn-secondary w-full sm:w-auto"
            >
              <Images className="h-4 w-4" aria-hidden="true" />
              See the app
            </button>
          </motion.div>

          <motion.div
            initial={reduce ? false : { opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="mt-8 flex items-center justify-center gap-2 text-sm text-muted lg:justify-start"
          >
            <Smartphone className="h-4 w-4 text-persaka-purple" aria-hidden="true" />
            <span>Built with {product.platform}</span>
          </motion.div>
        </div>

        {/* Product phone render (transparent PNG, shown without distortion). */}
        <motion.div
          initial={reduce ? false : { opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.15, ease: "easeOut" }}
          className="relative mx-auto flex w-full max-w-sm justify-center lg:max-w-md"
        >
          <div
            aria-hidden="true"
            className="absolute inset-0 -z-10 mx-auto my-auto h-72 w-72 rounded-full bg-persaka-gradient opacity-20 blur-3xl"
          />
          <img
            src={product.productPhone}
            alt={`${product.name} organiser dashboard shown on a smartphone`}
            width={543}
            height={724}
            fetchPriority="high"
            className="h-auto w-full max-w-[340px] drop-shadow-2xl"
          />
        </motion.div>
      </div>
    </section>
  );
}

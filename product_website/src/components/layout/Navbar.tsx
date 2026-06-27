import { useEffect, useState } from "react";
import { AnimatePresence, motion, useReducedMotion } from "motion/react";
import { Menu, X } from "lucide-react";
import { navItems, product } from "@/data/site";
import { cn, scrollToSection } from "@/lib/utils";

export function Navbar() {
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const reduce = useReducedMotion();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  // Lock body scroll while the mobile menu is open.
  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  // Close on Escape for keyboard accessibility.
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && setOpen(false);
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  const handleNav = (href: string) => {
    setOpen(false);
    scrollToSection(href.replace("#", ""));
  };

  return (
    <header className="fixed inset-x-0 top-0 z-50">
      <motion.nav
        aria-label="Primary"
        initial={false}
        animate={{
          y: 0,
          paddingTop: scrolled ? 8 : 14,
          paddingBottom: scrolled ? 8 : 14,
        }}
        transition={reduce ? { duration: 0 } : { duration: 0.25 }}
        className={cn(
          "mx-auto mt-3 flex w-[min(100%-1.5rem,72rem)] items-center justify-between rounded-2xl border px-4 transition-colors duration-300 sm:px-6",
          scrolled
            ? "border-black/[0.06] bg-white/85 shadow-card backdrop-blur-md"
            : "border-transparent bg-white/60 backdrop-blur-sm",
        )}
      >
        <a
          href="#home"
          onClick={(e) => {
            e.preventDefault();
            handleNav("#home");
          }}
          className="flex items-center gap-2.5"
          aria-label={`${product.name} — home`}
        >
          <img
            src={product.logo}
            alt=""
            width={36}
            height={36}
            className="h-9 w-9 rounded-full object-contain ring-1 ring-black/10"
          />
          <span className="font-heading text-base font-bold tracking-tight text-ink sm:text-lg">
            {product.shortName}
          </span>
        </a>

        {/* Desktop links */}
        <ul className="hidden items-center gap-1 lg:flex">
          {navItems.map((item) => (
            <li key={item.href}>
              <a
                href={item.href}
                onClick={(e) => {
                  e.preventDefault();
                  handleNav(item.href);
                }}
                className="rounded-lg px-3 py-2 text-sm font-medium text-muted transition-colors hover:bg-persaka-purple/5 hover:text-persaka-purple"
              >
                {item.label}
              </a>
            </li>
          ))}
        </ul>

        <div className="hidden lg:block">
          <a
            href="#contact"
            onClick={(e) => {
              e.preventDefault();
              handleNav("#contact");
            }}
            className="btn-primary px-5 py-2.5"
          >
            Get in touch
          </a>
        </div>

        {/* Mobile toggle */}
        <button
          type="button"
          className="inline-flex h-10 w-10 items-center justify-center rounded-lg text-ink transition-colors hover:bg-persaka-purple/5 lg:hidden"
          aria-label={open ? "Close menu" : "Open menu"}
          aria-expanded={open}
          aria-controls="mobile-menu"
          onClick={() => setOpen((v) => !v)}
        >
          {open ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
        </button>
      </motion.nav>

      {/* Mobile menu */}
      <AnimatePresence>
        {open && (
          <>
            <motion.div
              className="fixed inset-0 z-40 bg-ink/30 backdrop-blur-sm lg:hidden"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setOpen(false)}
              aria-hidden="true"
            />
            <motion.div
              id="mobile-menu"
              role="dialog"
              aria-modal="true"
              aria-label="Site menu"
              initial={{ opacity: 0, y: -12 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -12 }}
              transition={reduce ? { duration: 0 } : { duration: 0.2 }}
              className="absolute inset-x-3 top-[4.5rem] z-50 rounded-2xl border border-black/[0.06] bg-white p-3 shadow-soft lg:hidden"
            >
              <ul className="flex flex-col">
                {navItems.map((item) => (
                  <li key={item.href}>
                    <a
                      href={item.href}
                      onClick={(e) => {
                        e.preventDefault();
                        handleNav(item.href);
                      }}
                      className="block rounded-xl px-4 py-3 text-base font-medium text-ink transition-colors hover:bg-persaka-purple/5 hover:text-persaka-purple"
                    >
                      {item.label}
                    </a>
                  </li>
                ))}
              </ul>
              <a
                href="#contact"
                onClick={(e) => {
                  e.preventDefault();
                  handleNav("#contact");
                }}
                className="btn-primary mt-2 w-full"
              >
                Get in touch
              </a>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </header>
  );
}

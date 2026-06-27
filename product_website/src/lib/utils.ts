import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Smoothly scroll to a section id, accounting for the sticky navbar height.
 * Respects the user's reduced-motion preference.
 */
export function scrollToSection(id: string) {
  const el = document.getElementById(id);
  if (!el) return;
  const prefersReduced = window.matchMedia(
    "(prefers-reduced-motion: reduce)",
  ).matches;
  el.scrollIntoView({
    behavior: prefersReduced ? "auto" : "smooth",
    block: "start",
  });
}

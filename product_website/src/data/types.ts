import type { LucideIcon } from "lucide-react";

export interface NavItem {
  label: string;
  href: string; // section id, e.g. "#features"
}

export interface Feature {
  name: string;
  description: string; // what it does
  benefit: string; // why it matters to the user
  icon: LucideIcon;
  /** Optional emphasis flag for the bento layout. */
  span?: "wide" | "tall" | "normal";
}

export interface Benefit {
  title: string;
  description: string;
  icon: LucideIcon;
}

export interface Screenshot {
  title: string;
  caption: string;
  alt: string;
  /** Imported image URL, or null when a real screenshot still needs to be added. */
  image: string | null;
  icon: LucideIcon;
}

export interface TeamMember {
  name: string;
  role: string;
  responsibilities: string;
  image?: string;
  github?: string;
  linkedin?: string;
}

export interface ContactLink {
  label: string;
  value: string;
  href: string;
  icon: LucideIcon;
}

import { useState, type ReactNode } from "react";
import { AnimatePresence, motion } from "motion/react";
import { cn } from "@/lib/utils";

export interface HoverCardItem {
  title: string;
  description: string;
  icon?: ReactNode;
}

/**
 * Aceternity UI — Card Hover Effect (adapted).
 * A soft highlight follows the hovered card. Keyboard focus is supported via
 * focus-within so the effect is not mouse-only.
 */
export function HoverEffect({
  items,
  className,
}: {
  items: HoverCardItem[];
  className?: string;
}) {
  const [hovered, setHovered] = useState<number | null>(null);

  return (
    <div
      className={cn(
        "grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3",
        className,
      )}
    >
      {items.map((item, idx) => (
        <div
          key={item.title}
          className="group relative block h-full w-full p-1.5"
          onMouseEnter={() => setHovered(idx)}
          onMouseLeave={() => setHovered(null)}
        >
          <AnimatePresence>
            {hovered === idx && (
              <motion.span
                className="absolute inset-0 block rounded-2xl bg-persaka-purple/[0.06]"
                layoutId="hoverBackground"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1, transition: { duration: 0.15 } }}
                exit={{ opacity: 0, transition: { duration: 0.15, delay: 0.1 } }}
                aria-hidden="true"
              />
            )}
          </AnimatePresence>
          <div className="relative z-10 flex h-full flex-col gap-3 rounded-2xl border border-black/[0.06] bg-white p-6 shadow-card transition-colors duration-200 group-focus-within:border-persaka-purple/30 group-hover:border-persaka-purple/30">
            {item.icon && (
              <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-persaka-purple/10 text-persaka-purple">
                {item.icon}
              </div>
            )}
            <h3 className="font-heading text-base font-semibold text-ink">
              {item.title}
            </h3>
            <p className="text-sm leading-relaxed text-muted">
              {item.description}
            </p>
          </div>
        </div>
      ))}
    </div>
  );
}

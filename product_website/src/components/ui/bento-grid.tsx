import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

/**
 * Aceternity UI — Bento Grid (adapted).
 * A responsive bento-box layout for the feature showcase.
 */
export function BentoGrid({
  className,
  children,
}: {
  className?: string;
  children?: ReactNode;
}) {
  return (
    <div
      className={cn(
        "grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 lg:auto-rows-[16rem]",
        className,
      )}
    >
      {children}
    </div>
  );
}

export function BentoGridItem({
  className,
  title,
  description,
  benefit,
  icon,
}: {
  className?: string;
  title: string;
  description: string;
  benefit: string;
  icon?: ReactNode;
}) {
  return (
    <div
      className={cn(
        "group/bento flex h-full flex-col justify-between gap-4 rounded-2xl border border-black/[0.06] bg-white p-6 shadow-card transition-all duration-200 hover:-translate-y-1 hover:shadow-soft",
        className,
      )}
    >
      <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-persaka-gradient text-white shadow-soft transition-transform duration-200 group-hover/bento:scale-105">
        {icon}
      </div>
      <div className="space-y-2">
        <h3 className="font-heading text-lg font-semibold text-ink">{title}</h3>
        <p className="text-sm leading-relaxed text-muted">{description}</p>
        <p className="flex items-start gap-1.5 text-sm font-medium text-persaka-purple">
          <span aria-hidden="true" className="mt-px">
            ↳
          </span>
          <span>{benefit}</span>
        </p>
      </div>
    </div>
  );
}

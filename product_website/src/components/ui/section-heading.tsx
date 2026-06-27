import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { Reveal } from "./reveal";

export function SectionHeading({
  eyebrow,
  eyebrowClassName,
  title,
  description,
  align = "center",
  className,
}: {
  eyebrow?: string;
  eyebrowClassName?: string;
  title: ReactNode;
  description?: ReactNode;
  align?: "center" | "left";
  className?: string;
}) {
  return (
    <Reveal
      className={cn(
        "max-w-3xl",
        align === "center" ? "mx-auto text-center" : "text-left",
        className,
      )}
    >
      {eyebrow && (
        <span className={cn("eyebrow", eyebrowClassName)}>{eyebrow}</span>
      )}
      <h2 className="mt-4 text-3xl font-bold tracking-tight text-ink sm:text-4xl">
        {title}
      </h2>
      {description && (
        <p className="mt-4 text-base leading-relaxed text-muted sm:text-lg">
          {description}
        </p>
      )}
    </Reveal>
  );
}

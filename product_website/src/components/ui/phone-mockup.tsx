import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

/**
 * A clean device frame for displaying app screenshots without distortion.
 * Screenshots are object-contain so they are never stretched or cropped.
 */
export function PhoneMockup({
  src,
  alt,
  className,
  loading = "lazy",
  fallback,
}: {
  src?: string | null;
  alt: string;
  className?: string;
  loading?: "lazy" | "eager";
  fallback?: ReactNode;
}) {
  return (
    <div
      className={cn(
        "relative mx-auto aspect-[9/19] w-full max-w-[260px] rounded-[2.2rem] border-[10px] border-ink/90 bg-ink shadow-soft",
        className,
      )}
    >
      {/* Notch */}
      <div
        className="absolute left-1/2 top-0 z-10 h-5 w-28 -translate-x-1/2 rounded-b-2xl bg-ink/90"
        aria-hidden="true"
      />
      <div className="h-full w-full overflow-hidden rounded-[1.5rem] bg-white">
        {src ? (
          <img
            src={src}
            alt={alt}
            loading={loading}
            decoding="async"
            className="h-full w-full object-cover object-top"
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-gradient-to-br from-persaka-purple/5 to-persaka-red/5 p-6 text-center">
            {fallback}
          </div>
        )}
      </div>
    </div>
  );
}

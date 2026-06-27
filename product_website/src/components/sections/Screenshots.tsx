import { SectionHeading } from "@/components/ui/section-heading";
import { Reveal } from "@/components/ui/reveal";
import { PhoneMockup } from "@/components/ui/phone-mockup";
import { screenshots, product } from "@/data/site";

export function Screenshots() {
  return (
    <section
      id="screenshots"
      aria-labelledby="screenshots-heading"
      className="section-pad bg-white"
    >
      <div className="container-page">
        <SectionHeading
          eyebrow="App Screenshots"
          title={<span id="screenshots-heading">A look inside the app</span>}
          description="Real screens from the Flutter app, shown in device frames. Swipe on mobile to browse each view."
        />

        {/* Horizontal snap carousel on small screens, grid on large screens. */}
        <Reveal className="mt-14">
          <ul
            className="flex snap-x snap-mandatory gap-6 overflow-x-auto pb-6 [scrollbar-width:thin] lg:grid lg:grid-cols-5 lg:gap-6 lg:overflow-visible lg:pb-0"
            aria-label="Application screenshots"
          >
            {screenshots.map((shot) => {
              const Icon = shot.icon;
              return (
                <li
                  key={shot.title}
                  className="w-[78%] shrink-0 snap-center sm:w-[44%] lg:w-auto"
                >
                  <figure className="flex h-full flex-col">
                    {shot.image ? (
                      // Real product render is a transparent phone image — shown
                      // directly so it is never cropped or distorted.
                      <div className="relative flex items-center justify-center rounded-2xl bg-gradient-to-br from-persaka-purple/[0.06] to-persaka-red/[0.06] p-4">
                        <img
                          src={shot.image}
                          alt={shot.alt}
                          loading="lazy"
                          decoding="async"
                          className="mx-auto h-auto w-full max-w-[220px]"
                        />
                      </div>
                    ) : (
                      <PhoneMockup
                        alt={shot.alt}
                        loading="lazy"
                        fallback={
                          <div className="flex flex-col items-center gap-3 text-persaka-purple">
                            <span className="flex h-12 w-12 items-center justify-center rounded-xl bg-persaka-gradient text-white">
                              <Icon className="h-6 w-6" aria-hidden="true" />
                            </span>
                            <span className="text-xs font-medium text-muted">
                              Preview coming soon
                            </span>
                          </div>
                        }
                      />
                    )}
                    <figcaption className="mt-5 px-1">
                      <p className="flex items-center gap-2 font-heading text-base font-semibold text-ink">
                        <Icon
                          className="h-4 w-4 text-persaka-purple"
                          aria-hidden="true"
                        />
                        {shot.title}
                      </p>
                      <p className="mt-1 text-sm leading-relaxed text-muted">
                        {shot.caption}
                      </p>
                    </figcaption>
                  </figure>
                </li>
              );
            })}
          </ul>
        </Reveal>

        <p className="mt-6 text-center text-xs text-muted">
          Real screens from the live {product.shortName} Flutter app.
        </p>
      </div>
    </section>
  );
}

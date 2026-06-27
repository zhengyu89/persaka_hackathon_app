import { ArrowUpRight } from "lucide-react";
import { SectionHeading } from "@/components/ui/section-heading";
import { Reveal } from "@/components/ui/reveal";
import { contactEmail, contactLinks, product } from "@/data/site";

export function Contact() {
  return (
    <section
      id="contact"
      aria-labelledby="contact-heading"
      className="section-pad bg-white"
    >
      <div className="container-page">
        <Reveal className="relative overflow-hidden rounded-3xl bg-persaka-gradient px-6 py-14 text-center text-white sm:px-12 sm:py-16">
          <div
            aria-hidden="true"
            className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,rgba(255,255,255,0.18),transparent_55%)]"
          />
          <div className="relative z-10 mx-auto max-w-2xl">
            <SectionHeading
              eyebrow="Contact"
              eyebrowClassName="border-white/20 bg-white text-persaka-purple"
              title={
                <span id="contact-heading" className="text-white">
                  Want a demo or have a question?
                </span>
              }
              description={
                <span className="text-white/90">
                  We'd love to hear from organisers, judges, and teams. Reach out
                  and we'll get back to you.
                </span>
              }
            />

            <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
              <a
                href={`mailto:${contactEmail}?subject=Persaka%20Hackathon%20App%20Enquiry`}
                className="inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-white px-6 py-3 text-sm font-semibold text-persaka-purple shadow-soft transition-transform duration-200 hover:-translate-y-0.5 sm:w-auto sm:text-base"
              >
                Email us
                <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
              </a>
              <a
                href={product.repository}
                target="_blank"
                rel="noreferrer noopener"
                className="inline-flex w-full items-center justify-center gap-2 rounded-2xl border border-white/40 px-6 py-3 text-sm font-semibold text-white transition-colors duration-200 hover:bg-white/10 sm:w-auto sm:text-base"
              >
                View on GitHub
                <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
              </a>
            </div>

            <dl className="mt-10 grid gap-4 sm:grid-cols-2">
              {contactLinks.map((link) => {
                const Icon = link.icon;
                return (
                  <a
                    key={link.label}
                    href={link.href}
                    target={link.href.startsWith("http") ? "_blank" : undefined}
                    rel={
                      link.href.startsWith("http")
                        ? "noreferrer noopener"
                        : undefined
                    }
                    className="flex items-center gap-3 rounded-2xl bg-white/10 p-4 text-left backdrop-blur-sm transition-colors hover:bg-white/15"
                  >
                    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-white/20">
                      <Icon className="h-5 w-5" aria-hidden="true" />
                    </span>
                    <span className="min-w-0">
                      <dt className="text-xs font-semibold uppercase tracking-wider text-white/70">
                        {link.label}
                      </dt>
                      <dd className="truncate text-sm font-medium text-white">
                        {link.value}
                      </dd>
                    </span>
                  </a>
                );
              })}
            </dl>
          </div>
        </Reveal>
      </div>
    </section>
  );
}

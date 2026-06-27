import { Github, Linkedin } from "lucide-react";
import { SectionHeading } from "@/components/ui/section-heading";
import { Reveal } from "@/components/ui/reveal";
import { product, team } from "@/data/site";

function initials(name: string) {
  return name
    .split(" ")
    .map((n) => n[0])
    .filter(Boolean)
    .slice(0, 2)
    .join("")
    .toUpperCase();
}

export function Team() {
  return (
    <section
      id="team"
      aria-labelledby="team-heading"
      className="section-pad bg-canvas"
    >
      <div className="container-page">
        <SectionHeading
          eyebrow={`Team ${product.team.name}`}
          title={<span id="team-heading">The people behind the app</span>}
          description="A focused team covering AI, backend, and mobile development."
        />

        <ul className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {team.map((member, i) => (
            <Reveal as="li" key={member.name} delay={i * 0.05}>
              <article className="group flex h-full flex-col items-center rounded-2xl border border-black/[0.06] bg-white p-6 text-center shadow-card transition-all duration-200 hover:-translate-y-1 hover:shadow-soft">
                <div className="relative">
                  <div
                    aria-hidden="true"
                    className="absolute -inset-1 rounded-full bg-persaka-gradient opacity-0 blur transition-opacity duration-300 group-hover:opacity-60"
                  />
                  {member.image ? (
                    <img
                      src={member.image}
                      alt={`Portrait of ${member.name}`}
                      loading="lazy"
                      decoding="async"
                      width={96}
                      height={96}
                      className="relative h-24 w-24 rounded-full object-cover ring-2 ring-white"
                    />
                  ) : (
                    <div
                      className="relative flex h-24 w-24 items-center justify-center rounded-full bg-persaka-gradient font-heading text-2xl font-bold text-white"
                      aria-hidden="true"
                    >
                      {initials(member.name)}
                    </div>
                  )}
                </div>

                <h3 className="mt-5 font-heading text-lg font-semibold text-ink">
                  {member.name}
                </h3>
                <p className="mt-1 inline-flex rounded-full bg-persaka-purple/10 px-3 py-1 text-xs font-semibold text-persaka-purple">
                  {member.role}
                </p>
                <p className="mt-3 text-sm leading-relaxed text-muted">
                  {member.responsibilities}
                </p>

                {(member.github || member.linkedin) && (
                  <div className="mt-4 flex items-center gap-2">
                    {member.github && (
                      <a
                        href={member.github}
                        target="_blank"
                        rel="noreferrer noopener"
                        aria-label={`${member.name} on GitHub`}
                        className="flex h-9 w-9 items-center justify-center rounded-lg border border-black/10 text-muted transition-colors hover:border-persaka-purple/40 hover:text-persaka-purple"
                      >
                        <Github className="h-4 w-4" aria-hidden="true" />
                      </a>
                    )}
                    {member.linkedin && (
                      <a
                        href={member.linkedin}
                        target="_blank"
                        rel="noreferrer noopener"
                        aria-label={`${member.name} on LinkedIn`}
                        className="flex h-9 w-9 items-center justify-center rounded-lg border border-black/10 text-muted transition-colors hover:border-persaka-purple/40 hover:text-persaka-purple"
                      >
                        <Linkedin className="h-4 w-4" aria-hidden="true" />
                      </a>
                    )}
                  </div>
                )}
              </article>
            </Reveal>
          ))}
        </ul>
      </div>
    </section>
  );
}

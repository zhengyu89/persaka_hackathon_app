import { ArrowRight } from "lucide-react";
import { SectionHeading } from "@/components/ui/section-heading";
import { Reveal } from "@/components/ui/reveal";
import { problems, solutions } from "@/data/site";

export function ProblemSolution() {
  return (
    <section
      id="problem"
      aria-labelledby="problem-heading"
      className="section-pad bg-white"
    >
      <div className="container-page">
        <SectionHeading
          eyebrow="The problem & our solution"
          title={
            <span id="problem-heading">
              Running a hackathon shouldn't feel like herding spreadsheets
            </span>
          }
          description="Organisers and participants juggle too many disconnected tools. Persaka Hackathon replaces that chaos with one focused mobile workflow."
        />

        <div className="mt-14 grid gap-6 lg:grid-cols-2">
          {/* Problems */}
          <Reveal className="rounded-2xl border border-persaka-red/15 bg-persaka-red/[0.03] p-6 sm:p-8">
            <h3 className="flex items-center gap-2 font-heading text-lg font-semibold text-ink">
              <span className="inline-block h-2.5 w-2.5 rounded-full bg-persaka-red" aria-hidden="true" />
              The pain today
            </h3>
            <ul className="mt-6 space-y-5">
              {problems.map((p) => {
                const Icon = p.icon;
                return (
                  <li key={p.title} className="flex gap-4">
                    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-persaka-red/10 text-persaka-red">
                      <Icon className="h-5 w-5" aria-hidden="true" />
                    </span>
                    <div>
                      <p className="font-semibold text-ink">{p.title}</p>
                      <p className="mt-1 text-sm leading-relaxed text-muted">
                        {p.description}
                      </p>
                    </div>
                  </li>
                );
              })}
            </ul>
          </Reveal>

          {/* Solutions */}
          <Reveal
            delay={0.1}
            className="rounded-2xl border border-persaka-purple/15 bg-persaka-purple/[0.03] p-6 sm:p-8"
          >
            <h3 className="flex items-center gap-2 font-heading text-lg font-semibold text-ink">
              <span className="inline-block h-2.5 w-2.5 rounded-full bg-persaka-purple" aria-hidden="true" />
              How Persaka Hackathon helps
            </h3>
            <ul className="mt-6 space-y-5">
              {solutions.map((s) => {
                const Icon = s.icon;
                return (
                  <li key={s.title} className="flex gap-4">
                    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-persaka-gradient text-white">
                      <Icon className="h-5 w-5" aria-hidden="true" />
                    </span>
                    <div>
                      <p className="font-semibold text-ink">{s.title}</p>
                      <p className="mt-1 text-sm leading-relaxed text-muted">
                        {s.description}
                      </p>
                    </div>
                  </li>
                );
              })}
            </ul>
          </Reveal>
        </div>

        <Reveal
          delay={0.15}
          className="mx-auto mt-8 flex max-w-2xl items-center justify-center gap-3 rounded-2xl bg-persaka-gradient px-6 py-5 text-center text-sm font-medium text-white sm:text-base"
        >
          <span>
            The result: less admin overhead, fairer judging, and participants who
            always know what's next.
          </span>
          <ArrowRight className="hidden h-5 w-5 shrink-0 sm:block" aria-hidden="true" />
        </Reveal>
      </div>
    </section>
  );
}

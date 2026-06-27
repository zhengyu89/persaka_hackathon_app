import { SectionHeading } from "@/components/ui/section-heading";
import { Reveal } from "@/components/ui/reveal";
import { aboutPoints, product } from "@/data/site";

export function About() {
  return (
    <section
      id="about"
      aria-labelledby="about-heading"
      className="section-pad bg-white"
    >
      <div className="container-page">
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
          <div>
            <SectionHeading
              align="left"
              eyebrow="About the product"
              title={<span id="about-heading">Built for the people who run hackathons</span>}
            />
            <Reveal delay={0.05} className="mt-6 space-y-4 text-base leading-relaxed text-muted">
              <p>
                {product.name} is a mobile-first platform designed for{" "}
                <strong className="text-ink">participants, judges, and organisers</strong>{" "}
                of university hackathons. Its purpose is simple: take the entire
                event lifecycle — sign-up, team formation, registration,
                submissions, judging, schedule, and results — and make it
                manageable from a single app.
              </p>
              <p>
                It was built because hackathon logistics are usually stitched
                together from forms, spreadsheets, and chat groups that break down
                exactly when an event gets busy. By centralising everything in{" "}
                <strong className="text-ink">{product.platform}</strong>, the app
                keeps organisers in control and participants informed.
              </p>
              <p>
                The expected impact: smoother events, fairer and more transparent
                judging, and a better experience for everyone — so the focus stays
                on building great projects.
              </p>
            </Reveal>
          </div>

          <Reveal delay={0.1}>
            <dl className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              {aboutPoints.map((point) => (
                <div
                  key={point.label}
                  className="card-base p-6 transition-transform duration-200 hover:-translate-y-1"
                >
                  <dt className="text-xs font-semibold uppercase tracking-wider text-persaka-purple">
                    {point.label}
                  </dt>
                  <dd className="mt-2 font-heading text-lg font-semibold text-ink">
                    {point.value}
                  </dd>
                </div>
              ))}
            </dl>
            <div className="mt-4 flex items-center gap-4 rounded-2xl bg-persaka-gradient p-6 text-white">
              <img
                src={product.logo}
                alt=""
                className="h-14 w-14 rounded-full object-contain"
              />
              <div>
                <p className="font-heading text-lg font-bold">{product.name}</p>
                <p className="text-sm text-white/85">{product.tagline}</p>
              </div>
            </div>
          </Reveal>
        </div>
      </div>
    </section>
  );
}

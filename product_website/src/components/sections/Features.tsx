import { SectionHeading } from "@/components/ui/section-heading";
import { Reveal } from "@/components/ui/reveal";
import { BentoGrid, BentoGridItem } from "@/components/ui/bento-grid";
import { features } from "@/data/site";
import { cn } from "@/lib/utils";

const spanClass: Record<NonNullable<(typeof features)[number]["span"]>, string> =
  {
    wide: "lg:col-span-2",
    tall: "lg:row-span-2",
    normal: "",
  };

export function Features() {
  return (
    <section
      id="features"
      aria-labelledby="features-heading"
      className="section-pad bg-canvas"
    >
      <div className="container-page">
        <SectionHeading
          eyebrow="Features"
          title={<span id="features-heading">Everything an event needs, in one app</span>}
          description="Each feature is built around a real job to be done — and a clear benefit for the person doing it."
        />

        <Reveal className="mt-14">
          <BentoGrid>
            {features.map((feature) => {
              const Icon = feature.icon;
              return (
                <BentoGridItem
                  key={feature.name}
                  title={feature.name}
                  description={feature.description}
                  benefit={feature.benefit}
                  icon={<Icon className="h-6 w-6" aria-hidden="true" />}
                  className={cn(spanClass[feature.span ?? "normal"])}
                />
              );
            })}
          </BentoGrid>
        </Reveal>
      </div>
    </section>
  );
}

import { SectionHeading } from "@/components/ui/section-heading";
import { Reveal } from "@/components/ui/reveal";
import { HoverEffect } from "@/components/ui/card-hover-effect";
import { benefits } from "@/data/site";

export function Benefits() {
  const items = benefits.map((b) => {
    const Icon = b.icon;
    return {
      title: b.title,
      description: b.description,
      icon: <Icon className="h-5 w-5" aria-hidden="true" />,
    };
  });

  return (
    <section
      id="benefits"
      aria-labelledby="benefits-heading"
      className="section-pad bg-canvas"
    >
      <div className="container-page">
        <SectionHeading
          eyebrow="Why it matters"
          title={<span id="benefits-heading">Benefits people actually feel</span>}
          description="Beyond the feature list, here's the real value Persaka Hackathon delivers to everyone involved."
        />
        <Reveal className="mt-12">
          <HoverEffect items={items} />
        </Reveal>
      </div>
    </section>
  );
}

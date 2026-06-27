import { Github, Mail } from "lucide-react";
import { contactEmail, navItems, product } from "@/data/site";
import { scrollToSection } from "@/lib/utils";

export function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="border-t border-black/[0.06] bg-canvas">
      <div className="container-page py-14">
        <div className="grid gap-10 md:grid-cols-3">
          <div className="max-w-sm">
            <a
              href="#home"
              onClick={(e) => {
                e.preventDefault();
                scrollToSection("home");
              }}
              className="flex items-center gap-2.5"
              aria-label={`${product.name} — back to top`}
            >
              <img
                src={product.logo}
                alt=""
                width={40}
                height={40}
                className="h-10 w-10 rounded-full object-contain ring-1 ring-black/10"
              />
              <span className="font-heading text-lg font-bold text-ink">
                {product.shortName}
              </span>
            </a>
            <p className="mt-4 text-sm leading-relaxed text-muted">
              {product.tagline} One mobile app for teams, registration,
              submissions, judging, schedule, and live results.
            </p>
          </div>

          <nav aria-label="Footer" className="md:justify-self-center">
            <h2 className="font-heading text-sm font-semibold uppercase tracking-wider text-ink">
              Navigate
            </h2>
            <ul className="mt-4 space-y-2">
              {navItems.map((item) => (
                <li key={item.href}>
                  <a
                    href={item.href}
                    onClick={(e) => {
                      e.preventDefault();
                      scrollToSection(item.href.replace("#", ""));
                    }}
                    className="text-sm text-muted transition-colors hover:text-persaka-purple"
                  >
                    {item.label}
                  </a>
                </li>
              ))}
            </ul>
          </nav>

          <div className="md:justify-self-end">
            <h2 className="font-heading text-sm font-semibold uppercase tracking-wider text-ink">
              Connect
            </h2>
            <div className="mt-4 flex flex-col gap-3">
              <a
                href={`mailto:${contactEmail}`}
                className="inline-flex items-center gap-2 text-sm text-muted transition-colors hover:text-persaka-purple"
              >
                <Mail className="h-4 w-4" aria-hidden="true" />
                {contactEmail}
              </a>
              <a
                href={product.repository}
                target="_blank"
                rel="noreferrer noopener"
                className="inline-flex items-center gap-2 text-sm text-muted transition-colors hover:text-persaka-purple"
              >
                <Github className="h-4 w-4" aria-hidden="true" />
                GitHub repository
              </a>
            </div>
          </div>
        </div>

        <div className="mt-12 flex flex-col items-center justify-between gap-3 border-t border-black/[0.06] pt-6 text-center sm:flex-row sm:text-left">
          <p className="text-sm text-muted">
            &copy; {year} Team {product.team.name}. All rights reserved.
          </p>
          <p className="text-sm text-muted">
            Built with{" "}
            <span className="font-semibold text-persaka-purple">React</span> &amp;{" "}
            <span className="font-semibold text-persaka-red">Flutter</span>.
          </p>
        </div>
      </div>
    </footer>
  );
}

import { Link } from "react-router-dom";

export default function Footer() {
  return (
    <footer className="border-t bg-white dark:bg-background">
      <div className="container mx-auto flex flex-col items-center justify-between gap-4 py-8 md:h-20 md:flex-row">
        <p className="text-center text-sm leading-loose text-muted-foreground md:text-left">
          © {new Date().getFullYear()} NewtonX Pro. Built for modern B2B
          sign‑ups.
        </p>
        <nav className="flex items-center gap-6 text-sm text-muted-foreground">
          <Link to="/professionals" className="hover:text-foreground">
            Professionals
          </Link>
          <Link to="/add" className="hover:text-foreground">
            Add Professional
          </Link>
          <a
            href="https://www.newtonx.com/"
            target="_blank"
            rel="noreferrer"
            className="hover:text-foreground"
          >
            NewtonX.com →
          </a>
        </nav>
      </div>
    </footer>
  );
}

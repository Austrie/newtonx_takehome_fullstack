import { Link, NavLink, useLocation } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export default function Header() {
  const location = useLocation();
  const isActive = (to: string) => location.pathname === to;
  return (
    <header className="sticky top-0 z-40 w-full border-b bg-white/70 backdrop-blur supports-[backdrop-filter]:bg-white/60 dark:bg-background/60">
      <div className="container mx-auto flex h-16 items-center justify-between">
        <Link to="/" className="flex items-center gap-2">
          <span className="inline-flex h-8 w-8 items-center justify-center rounded-md bg-gradient-to-tr from-primary to-blue-400 text-white font-black">
            N
          </span>
          <span className="text-lg font-semibold tracking-tight">
            NewtonX Pro
          </span>
        </Link>
        <nav className="hidden gap-6 md:flex">
          <NavLink
            to="/professionals"
            className={({ isActive: a }) =>
              cn(
                "text-sm font-medium text-muted-foreground hover:text-foreground",
                (a || isActive("/professionals")) && "text-foreground",
              )
            }
          >
            Professionals
          </NavLink>
          <NavLink
            to="/add"
            className={({ isActive: a }) =>
              cn(
                "text-sm font-medium text-muted-foreground hover:text-foreground",
                (a || isActive("/add")) && "text-foreground",
              )
            }
          >
            Add Professional
          </NavLink>
        </nav>
        <div className="flex items-center gap-2">
          <Button asChild variant="outline" className="hidden md:inline-flex">
            <Link to="/professionals">View List</Link>
          </Button>
          <Button asChild>
            <Link to="/add">Add</Link>
          </Button>
        </div>
      </div>
    </header>
  );
}

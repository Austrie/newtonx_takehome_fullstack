import { useQuery } from "@tanstack/react-query";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { useState } from "react";
import {
  ProfessionalsAPI,
  type Professional,
  type SignupSource,
} from "@/lib/api";
import { Link } from "react-router-dom";

export default function ProfessionalsPage() {
  const [source, setSource] = useState<SignupSource | undefined>(undefined);
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ["professionals", source],
    queryFn: () => ProfessionalsAPI.list(source),
  });

  return (
    <main className="container py-10">
      <div className="mb-6 flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">
            Professionals
          </h1>
          <p className="text-muted-foreground">
            Unified view across direct, partner, and internal sources.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button asChild variant="outline">
            <Link to="/add">Add Professional</Link>
          </Button>
          <Button onClick={() => refetch()}>Refresh</Button>
        </div>
      </div>

      <div className="mb-4 flex items-center gap-3">
        <label className="text-sm font-medium">Filter by source</label>
        <Select
          value={source ?? "all"}
          onValueChange={(v) =>
            setSource(v === "all" ? undefined : (v as SignupSource))
          }
        >
          <SelectTrigger className="w-48">
            <SelectValue placeholder="All sources" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All</SelectItem>
            <SelectItem value="direct">Direct</SelectItem>
            <SelectItem value="partner">Partner</SelectItem>
            <SelectItem value="internal">Internal</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {isLoading && <p className="text-muted-foreground">Loading…</p>}
      {error && (
        <p className="text-destructive">
          {(error as Error).message || "Failed to load"}
        </p>
      )}

      {!isLoading && data && (
        <div className="rounded-lg border bg-card">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Full Name</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Phone</TableHead>
                <TableHead>Company</TableHead>
                <TableHead>Job Title</TableHead>
                <TableHead>Source</TableHead>
                <TableHead>Created</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-muted-foreground">
                    No professionals yet.
                  </TableCell>
                </TableRow>
              ) : (
                data.map((p: Professional) => (
                  <TableRow key={(p.id ?? `${p.email}-${p.phone}`) as string}>
                    <TableCell className="font-medium">{p.full_name}</TableCell>
                    <TableCell>{p.email ?? "—"}</TableCell>
                    <TableCell>{p.phone ?? "—"}</TableCell>
                    <TableCell>{p.company_name ?? "—"}</TableCell>
                    <TableCell>{p.job_title ?? "—"}</TableCell>
                    <TableCell className="capitalize">{p.source}</TableCell>
                    <TableCell>
                      {p.created_at
                        ? new Date(p.created_at).toLocaleString()
                        : "—"}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      )}
    </main>
  );
}

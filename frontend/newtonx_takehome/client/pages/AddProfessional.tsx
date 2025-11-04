import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useMutation } from "@tanstack/react-query";
import {
  ProfessionalsAPI,
  type Professional,
  type SignupSource,
} from "@/lib/api";
import { toast } from "sonner";
import { Link, useNavigate } from "react-router-dom";

const schema = z.object({
  full_name: z.string().min(2, { message: "Name is required" }),
  email: z.string().email("Invalid email").optional().or(z.literal("")),
  phone: z.string().optional().or(z.literal("")),
  company_name: z.string().optional().or(z.literal("")),
  job_title: z.string().optional().or(z.literal("")),
  source: z.enum(["direct", "partner", "internal"]).default("direct"),
  resume: z
    .instanceof(File)
    .optional()
    .or(z.any().refine((v) => v === undefined, { message: "" })),
});

type FormValues = z.infer<typeof schema>;

export default function AddProfessionalPage() {
  const navigate = useNavigate();
  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { source: "direct" },
  });

  const { mutateAsync } = useMutation({
    mutationFn: async (values: FormValues) => {
      const { resume, ...rest } = values;
      const payload: Professional = {
        full_name: rest.full_name,
        email: rest.email || undefined,
        phone: rest.phone || undefined,
        company_name: rest.company_name || undefined,
        job_title: rest.job_title || undefined,
        source: rest.source as SignupSource,
      };
      return ProfessionalsAPI.create(payload, resume);
    },
  });

  const onSubmit = async (values: FormValues) => {
    try {
      await mutateAsync(values);
      toast.success("Professional added");
      navigate("/professionals");
    } catch (e) {
      toast.error((e as Error).message);
    }
  };

  const selectedFile = watch("resume");

  return (
    <main className="container mx-auto max-w-2xl py-10">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">
            Add Professional
          </h1>
          <p className="text-muted-foreground">
            Create a new professional; supports optional PDF resume upload.
          </p>
        </div>
        <Button asChild variant="outline">
          <Link to="/professionals">Back to list</Link>
        </Button>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        <div>
          <label className="mb-1 block text-sm font-medium">Full Name</label>
          <Input placeholder="Jane Doe" {...register("full_name")} />
          {errors.full_name && (
            <p className="mt-1 text-sm text-destructive">
              {errors.full_name.message}
            </p>
          )}
        </div>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <label className="mb-1 block text-sm font-medium">Email</label>
            <Input
              type="email"
              placeholder="jane@company.com"
              {...register("email")}
            />
            {errors.email && (
              <p className="mt-1 text-sm text-destructive">
                {errors.email.message as string}
              </p>
            )}
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium">Phone</label>
            <Input
              type="tel"
              placeholder="+1 555 123 4567"
              {...register("phone")}
            />
          </div>
        </div>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <label className="mb-1 block text-sm font-medium">Company</label>
            <Input placeholder="Acme Inc." {...register("company_name")} />
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium">Job Title</label>
            <Input placeholder="VP, Product" {...register("job_title")} />
          </div>
        </div>

        <div>
          <label className="mb-1 block text-sm font-medium">Source</label>
          <Select
            value={watch("source")}
            onValueChange={(v) => setValue("source", v as FormValues["source"])}
          >
            <SelectTrigger>
              <SelectValue placeholder="Select a source" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="direct">Direct</SelectItem>
              <SelectItem value="partner">Partner</SelectItem>
              <SelectItem value="internal">Internal</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div>
          <label className="mb-1 block text-sm font-medium">Resume (PDF)</label>
          <input
            type="file"
            accept="application/pdf"
            onChange={(e) => setValue("resume", e.target.files?.[0])}
            className="block w-full text-sm file:mr-4 file:rounded-md file:border file:border-input file:bg-background file:px-3 file:py-2 file:text-sm file:font-medium file:text-foreground hover:file:bg-accent hover:file:text-accent-foreground"
          />
          {selectedFile && (
            <p className="mt-1 text-xs text-muted-foreground">
              Selected: {(selectedFile as File)?.name}
            </p>
          )}
        </div>

        <div className="flex items-center gap-3 pt-2">
          <Button type="submit" disabled={isSubmitting}>
            Submit
          </Button>
          <Button
            type="button"
            variant="outline"
            onClick={() => window.history.back()}
          >
            Cancel
          </Button>
        </div>
      </form>

      <section className="mt-10 rounded-lg border bg-muted/30 p-4 text-sm text-muted-foreground">
        <h2 className="mb-2 text-sm font-semibold text-foreground">
          Resume handling (frontend ready)
        </h2>
        <ul className="list-disc space-y-1 pl-6">
          <li>
            Sends multipart/form-data when a PDF is attached (field name:{" "}
            <code>resume</code>).
          </li>
          <li>
            Backend can extract text with a worker (e.g., PyPDF, Tika) and map
            to fields via heuristics or LLMs.
          </li>
          <li>
            Consider returning extracted fields to confirm before final save.
          </li>
        </ul>
      </section>
    </main>
  );
}

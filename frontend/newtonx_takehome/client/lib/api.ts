export type SignupSource = "direct" | "partner" | "internal";

export interface Professional {
  id?: number;
  full_name: string;
  email?: string;
  company_name?: string;
  job_title?: string;
  phone?: string;
  source: SignupSource;
  created_at?: string;
}

export interface BulkUpsertResult {
  success: Professional[];
  failed: { index: number; reason: string }[];
}

const API_BASE = "http://localhost:8000/api";

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, init);
  if (!res.ok) {
    let message = `Request failed with ${res.status}`;
    try {
      const body = await res.json();
      message = (body?.message || body?.detail || message) as string;
    } catch {}
    throw new Error(message);
  }
  return (await res.json()) as T;
}

export const ProfessionalsAPI = {
  list: (source?: SignupSource) => {
    const q = source ? `?source=${encodeURIComponent(source)}` : "";
    return request<Professional[]>(`/professionals/${q}`);
  },
  create: (data: Professional, file?: File) => {
    if (file) {
      const form = new FormData();
      Object.entries(data).forEach(([k, v]) => {
        if (v != null) form.append(k, String(v));
      });
      form.append("resume", file);
      return request<Professional>(`/professionals/`, {
        method: "POST",
        body: form,
      });
    }
    return request<Professional>(`/professionals/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
  },
  bulk: (records: Professional[]) =>
    request<BulkUpsertResult>(`/professionals/bulk`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(records),
    }),
};

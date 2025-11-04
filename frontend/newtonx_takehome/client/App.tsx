import "./global.css";

import { Toaster } from "@/components/ui/toaster";
import { createRoot } from "react-dom/client";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Index from "./pages/Index";
import NotFound from "./pages/NotFound";
import Header from "./components/site/Header";
import Footer from "./components/site/Footer";
import ProfessionalsPage from "./pages/Professionals";
import AddProfessionalPage from "./pages/AddProfessional";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <Header />
        <Routes>
          <Route path="/" element={<Index />} />
          <Route path="/professionals" element={<ProfessionalsPage />} />
          <Route path="/add" element={<AddProfessionalPage />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
        <Footer />
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

// Ensure we only call createRoot once (protect against HMR double-mounts)
const ROOT_ELEMENT = document.getElementById("root")!;
const _win = window as any;
if (!_win.__APP_ROOT__) {
  _win.__APP_ROOT__ = createRoot(ROOT_ELEMENT);
}
const ROOT = _win.__APP_ROOT__;
ROOT.render(<App />);

// HMR: unmount on module replacement to avoid duplicate roots and to allow clean reloads
if (import.meta.hot) {
  import.meta.hot.accept();
  import.meta.hot.dispose(() => {
    try {
      ROOT.unmount();
    } catch (e) {
      // ignore
    }
  });
}

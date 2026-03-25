'use client';

import { useEffect, useId, useRef } from 'react';

interface MermaidProps {
  chart: string;
}

export function Mermaid({ chart }: MermaidProps) {
  const id = useId();
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const cleanId = `mermaid-${id.replace(/:/g, '')}`;

    Promise.all([import('mermaid'), import('dompurify')]).then(
      ([mermaidMod, domPurifyMod]) => {
        const mermaid = mermaidMod.default;
        const DOMPurify = domPurifyMod.default;

        mermaid.initialize({
          startOnLoad: false,
          theme: 'default',
          securityLevel: 'loose',
        });

        mermaid.render(cleanId, chart).then(({ svg }) => {
          if (ref.current) {
            const sanitized = DOMPurify.sanitize(svg, {
              USE_PROFILES: { svg: true, svgFilters: true },
            });
            ref.current.textContent = '';
            const parser = new DOMParser();
            const doc = parser.parseFromString(sanitized, 'image/svg+xml');
            const svgEl = doc.documentElement;
            ref.current.appendChild(svgEl);
          }
        });
      },
    );
  }, [chart, id]);

  return (
    <div
      ref={ref}
      className="my-6 flex justify-center overflow-auto rounded-lg border bg-card p-4"
    />
  );
}

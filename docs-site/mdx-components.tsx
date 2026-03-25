import defaultMdxComponents from 'fumadocs-ui/mdx';
import { Mermaid } from '@/components/mermaid';
import type { MDXComponents } from 'mdx/types';

export function useMDXComponents(components: MDXComponents): MDXComponents {
  return {
    ...defaultMdxComponents,
    ...components,
    // Intercept code blocks — render mermaid diagrams as interactive charts
    pre: ({ children, ...props }: React.ComponentProps<'pre'>) => {
      const code = (children as React.ReactElement)?.props as
        | { className?: string; children?: string }
        | undefined;

      if (code?.className?.includes('language-mermaid') && code.children) {
        return <Mermaid chart={code.children.trim()} />;
      }

      return <pre {...props}>{children}</pre>;
    },
  };
}

'use client';

import { useEffect } from 'react';

interface ErrorProps {
  error: Error;
  reset: () => void;
}

export default function Error({ error, reset }: ErrorProps) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div style={{ padding: '24px' }}>
      <h2>Something went wrong</h2>
      <p>Failed to load notes.</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}

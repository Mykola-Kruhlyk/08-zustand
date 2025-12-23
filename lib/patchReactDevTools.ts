// lib/patchReactDevTools.ts

if (typeof window !== 'undefined') {
  try {
    const originalConsoleError = console.error;

    console.error = (...args: any[]) => {
      // Фільтруємо warning про Suspense cleanup
      if (
        typeof args[0] === 'string' &&
        args[0].includes(
          'We are cleaning up async info that was not on the parent Suspense boundary'
        )
      ) {
        return; // ігноруємо цей warning
      }
      // Все інше залишаємо
      originalConsoleError(...args);
    };
  } catch (err) {
    console.warn('Patch React DevTools failed', err);
  }
}

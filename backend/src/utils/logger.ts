export const logger = {
  info: (message: string, ...meta: unknown[]) => {
    // eslint-disable-next-line no-console
    console.log(`[INFO] ${new Date().toISOString()} - ${message}`, ...meta);
  },
  warn: (message: string, ...meta: unknown[]) => {
    // eslint-disable-next-line no-console
    console.warn(`[WARN] ${new Date().toISOString()} - ${message}`, ...meta);
  },
  error: (message: string, ...meta: unknown[]) => {
    // eslint-disable-next-line no-console
    console.error(`[ERROR] ${new Date().toISOString()} - ${message}`, ...meta);
  },
  debug: (message: string, ...meta: unknown[]) => {
    if (process.env.NODE_ENV !== 'production') {
      // eslint-disable-next-line no-console
      console.debug(`[DEBUG] ${new Date().toISOString()} - ${message}`, ...meta);
    }
  },
};

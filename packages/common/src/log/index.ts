import log4js from 'log4js';

log4js.addLayout('json', (config) => (logEvent) => {
  return JSON.stringify(logEvent) + config.separator;
});

export function init(name: string): log4js.Logger {
  const logger = log4js.getLogger(name);
  return logger;
}

export const log = {
  init,
  getLogger: (name: string) => log4js.getLogger(name),
  configure: (config: log4js.Configuration) => log4js.configure(config),
};

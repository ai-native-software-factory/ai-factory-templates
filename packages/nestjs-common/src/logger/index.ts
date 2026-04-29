import { Module, Global, Provider } from '@nestjs/common';
import { pino, Logger as PinoLogger } from 'pino';

export const LOGGER_OPTIONS = 'LOGGER_OPTIONS';

export interface LoggerOptions {
  level?: string;
  prettyPrint?: boolean;
}

@Global()
@Module({
  providers: [
    {
      provide: PinoLogger,
      inject: [LOGGER_OPTIONS],
      useFactory: (options: LoggerOptions) =>
        pino({
          level: options.level || 'info',
          transport: options.prettyPrint
            ? { target: 'pino-pretty', options: { colorize: true } }
            : undefined,
        }),
    },
  ],
  exports: [PinoLogger],
})
export class LoggerModule {
  static forRoot(options: LoggerOptions): Provider {
    return { provide: LOGGER_OPTIONS, useValue: options };
  }
}

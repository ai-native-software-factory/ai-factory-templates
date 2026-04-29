import { Module, Global, Provider } from '@nestjs/common';

export const NATS_OPTIONS = 'NATS_OPTIONS';

export interface NatsOptions {
  servers?: string[];
  name?: string;
}

@Global()
@Module({
  providers: [
    {
      provide: NATS_OPTIONS,
      useValue: { servers: ['nats://localhost:4222'] },
    },
  ],
  exports: [NATS_OPTIONS],
})
export class RemoteModule {
  static forRoot(options: NatsOptions): Provider {
    return { provide: NATS_OPTIONS, useValue: options };
  }
}

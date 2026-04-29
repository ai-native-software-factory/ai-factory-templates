import { Module, Global, Provider } from '@nestjs/common';
import { Redis } from 'ioredis';

export const REDIS_CLIENT = 'REDIS_CLIENT';

export const CACHE_OPTIONS = 'CACHE_OPTIONS';

export interface RedisOptions {
  host?: string;
  port?: number;
  password?: string;
  db?: number;
}

@Global()
@Module({
  providers: [
    {
      provide: REDIS_CLIENT,
      inject: [CACHE_OPTIONS],
      useFactory: (options: RedisOptions) =>
        new Redis({
          host: options.host || 'localhost',
          port: options.port || 6379,
          password: options.password || undefined,
          db: options.db || 0,
        }),
    },
  ],
  exports: [REDIS_CLIENT],
})
export class CacheModule {
  static forRoot(options: RedisOptions): Provider {
    return {
      provide: CACHE_OPTIONS,
      useValue: options,
    };
  }
}

export const InjectRedis = () => import('@nestjs/common').then(m => m.Inject(REDIS_CLIENT));

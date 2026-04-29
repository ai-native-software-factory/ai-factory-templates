import { Module, Global } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

export const DATABASE_OPTIONS = 'DATABASE_OPTIONS';

@Global()
@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      inject: [DATABASE_OPTIONS],
      useFactory: (options: Record<string, unknown>) => options,
    }),
  ],
  exports: [TypeOrmModule],
})
export class DatabaseModule {
  static forRoot(options: Record<string, unknown>) {
    return {
      module: DatabaseModule,
      providers: [{ provide: DATABASE_OPTIONS, useValue: options }],
      exports: [TypeOrmModule],
    };
  }
}

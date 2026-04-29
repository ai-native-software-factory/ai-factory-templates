/**
 * Core Module
 * 核心模块：Config、Logger、Cache 等全局模块
 */
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { LoggerModule } from './logger';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    LoggerModule,
  ],
  exports: [ConfigModule, LoggerModule],
})
export class CoreModule {}

import { Module } from '@nestjs/common';
import { ExampleModule } from './example/example.module';

/**
 * API Module
 * 业务模块汇总
 * 在此注册所有业务模块
 */
@Module({
  imports: [ExampleModule],
})
export class ApiModule {}

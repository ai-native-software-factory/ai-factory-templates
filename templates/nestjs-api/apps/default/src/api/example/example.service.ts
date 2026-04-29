import { Injectable } from '@nestjs/common';
import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNumber } from 'class-validator';

/**
 * 示例服务
 */
@Injectable()
export class ExampleService {
  @ApiProperty({ description: '获取示例数据' })
  getExample(): string {
    return 'Hello from ExampleService!';
  }

  @ApiProperty({ description: '计算示例' })
  calculate(a: number, b: number): number {
    return a + b;
  }
}

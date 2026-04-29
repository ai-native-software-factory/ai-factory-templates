import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { ExampleService } from './example.service';
import { IsString, IsNumber } from 'class-validator';

class CreateExampleDto {
  @IsString()
  name: string;

  @IsNumber()
  value: number;
}

@ApiTags('示例')
@Controller('example')
export class ExampleController {
  constructor(private readonly exampleService: ExampleService) {}

  @Get()
  @ApiOperation({ summary: '获取示例数据' })
  @ApiResponse({ status: 200, description: '返回示例字符串' })
  getExample(): string {
    return this.exampleService.getExample();
  }

  @Post('calculate')
  @ApiOperation({ summary: '计算两个数的和' })
  @ApiResponse({ status: 201, description: '返回计算结果' })
  calculate(@Body() dto: CreateExampleDto): number {
    return this.exampleService.calculate(dto.value, dto.value * 2);
  }
}

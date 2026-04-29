/**
 * Application Bootstrap
 * 应用启动入口，统一初始化流程
 */
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { NestFastifyApplication, FastifyAdapter } from '@nestjs/platform-fastify';
import { Logger } from './logger';
import type { AppModule } from '../../apps/default/src/app.module';

export async function ApplicationBootstrap(module: any, port = 3000) {
  const app = await NestFactory.create(module, new FastifyAdapter(), {
    logger: new Logger(),
  });

  // 全局前缀
  app.setGlobalPrefix('api');

  // CORS
  app.enableCors();

  // 全局验证管道
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  // Swagger API 文档
  const config = new DocumentBuilder()
    .setTitle('API Documentation')
    .setDescription('API 描述')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  await app.listen(port, '0.0.0.0');
  const url = await app.getUrl();
  console.log(`Application is running on: ${url}`);
  console.log(`Swagger docs: ${url}/docs`);

  return app;
}

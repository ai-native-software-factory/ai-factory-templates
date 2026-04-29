/**
 * Remote Module
 * RPC 远程调用模块 (NATS)
 */
import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';

@Module({
  imports: [
    ClientsModule.register([
      {
        name: 'NATS_SERVICE',
        transport: Transport.NATS,
        options: {
          url: process.env.NATS_URL || 'nats://localhost:4222',
        },
      },
    ]),
  ],
  exports: [ClientsModule],
})
export class RemoteModule {}

import { Module } from '@nestjs/common';
import { CoreModule, DatabaseModule, RemoteModule } from '@iplayabc/common';
import { ApiModule } from './api/api.module';

@Module({
  imports: [ApiModule, CoreModule, DatabaseModule, RemoteModule],
})
export class ApplicationModule {}

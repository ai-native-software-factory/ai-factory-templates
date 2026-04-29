import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { PinoLogger } from '../logger';

export const JWT_SECRET = 'JWT_SECRET';
export const JWT_OPTIONS = 'JWT_OPTIONS';

export interface JwtAuthOptions {
  secret?: string;
  expiresIn?: string;
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    @Inject(JWT_SECRET) private secret: string,
    private logger: PinoLogger,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid authorization header');
    }
    const token = authHeader.substring(7);
    try {
      const jwt = require('jsonwebtoken');
      const decoded = jwt.verify(token, this.secret);
      request.user = decoded;
      return true;
    } catch (e) {
      this.logger.warn({ err: e }, 'JWT verification failed');
      throw new UnauthorizedException('Invalid token');
    }
  }
}

export const provideJwtAuth = (options: JwtAuthOptions = {}) => ({
  provide: JWT_SECRET,
  useValue: options.secret || process.env.JWT_SECRET || 'default-secret-change-me',
});

import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || '!@#$3j...08*&';
const JWT_EXPIRE_TIME = Number(process.env.JWT_EXPIRE_SECONDS || 30 * 24 * 3600);

export function create(payload: Record<string, unknown>): string {
  const p = { ...payload };
  delete p.iat;
  delete p.exp;
  return jwt.sign(p, JWT_SECRET, { expiresIn: JWT_EXPIRE_TIME });
}

export function decodeToken(token: string): unknown {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch {
    return null;
  }
}

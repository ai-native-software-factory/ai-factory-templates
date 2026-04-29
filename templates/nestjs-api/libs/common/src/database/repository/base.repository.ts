/**
 * Base Repository
 * 通用 Repository 基类，提供常用的 CRUD 操作
 */
import { Repository, FindOptionsWhere, DeepPartial } from 'typeorm';

export abstract class BaseRepository<T> {
  protected constructor(protected readonly repository: Repository<T>) {}

  async findById(id: number | string): Promise<T | null> {
    return this.repository.findOne({ where: id as FindOptionsWhere<T> });
  }

  async findAll(): Promise<T[]> {
    return this.repository.find();
  }

  async create(data: DeepPartial<T>): Promise<T> {
    const entity = this.repository.create(data);
    return this.repository.save(entity);
  }

  async update(id: number | string, data: DeepPartial<T>): Promise<T | null> {
    await this.repository.update(id as FindOptionsWhere<T>, data as any);
    return this.findById(id);
  }

  async delete(id: number | string): Promise<boolean> {
    const result = await this.repository.delete(id as FindOptionsWhere<T>);
    return result.affected > 0;
  }
}

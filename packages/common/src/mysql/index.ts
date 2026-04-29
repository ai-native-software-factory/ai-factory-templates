import mysql2 from 'mysql2/promise';

interface DbConfig {
  host: string;
  port: number;
  user: string;
  password: string;
  database: string;
  waitForConnections?: boolean;
  connectionLimit?: number;
  queueLimit?: number;
}

interface WhereParams {
  [key: string]: unknown;
}

interface SelectParams {
  column?: string;
  select?: string;
  group?: string;
  order?: string;
  limit?: [number, number];
  page?: [number, number];
}

interface PagerResult {
  rows: unknown[];
  total: number;
  displayCount: number;
  pageNum: number;
  start: number;
  end: number;
  currentPage: number;
}

function createMysql(config: DbConfig) {
  const pool = mysql2.createPool({
    ...config,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  });

  async function run(sql: string, params?: unknown[]): Promise<unknown[]> {
    const formatSQL = params ? mysql2.format(sql, params) : sql;
    const dSQL = formatSQL.trim().replace(/\s+/g, ' ');
    const [rows] = await pool.query(dSQL);
    return rows as unknown[];
  }

  async function query(sql: string, params?: unknown[]): Promise<[unknown[], unknown]> {
    const [rows, fields] = await pool.query(sql, params);
    return [rows, fields];
  }

  async function selectOne(tableName: string, whereParams: WhereParams): Promise<unknown> {
    const rows = await select(tableName, whereParams);
    return rows[0];
  }

  async function select(tableName: string, whereParam: WhereParams | string, params?: SelectParams): Promise<unknown[]> {
    let sql = `select ${(params && (params.column || params.select)) || '*'} from \`${tableName}\``;
    if (typeof whereParam === 'object') {
      const sqlWhere = pool.escape(whereParam).replace(/,/g, ' and');
      if (sqlWhere && sqlWhere.length > 0) sql = `${sql} where ${sqlWhere}`;
    } else if (typeof whereParam === 'string') {
      sql = `${sql} where ${whereParam}`;
    }
    if (params) {
      if (params.group) sql = `${sql} group by ${params.group}`;
      if (params.order) sql = `${sql} order by ${params.order}`;
      if (params.limit) sql = `${sql} limit ${params.limit[0]},${params.limit[1]}`;
    }
    return run(sql);
  }

  async function pager(allQuery: string, params: unknown[] = [], page = 1, displayCount = 10): Promise<PagerResult> {
    if (page === 'all') {
      const rows = await run(allQuery, params);
      return { rows, total: rows.length, displayCount, pageNum: 1, start: 1, end: 1, currentPage: 1 };
    }
    page = +page;
    displayCount = +displayCount;
    let queryStr = allQuery.trim();
    if (queryStr.endsWith(';')) queryStr = queryStr.slice(0, -1);

    const totalSql = `select count(*) as total from (${queryStr}) as T`;
    const totalRows = await run(totalSql);
    const total = (totalRows[0] as { total: number }).total;

    const pageNum = Math.ceil(total / displayCount);
    if (page >= pageNum) page = pageNum;
    const offset = Math.max(0, (page - 1) * displayCount);
    const dataSql = `${queryStr} limit ${offset},${displayCount}`;
    const rows = await run(dataSql);

    return {
      rows,
      total,
      displayCount,
      pageNum,
      start: total === 0 ? 0 : offset,
      end: Math.min(page * displayCount, total),
      currentPage: page,
    };
  }

  async function insert(tableName: string, objSet: Record<string, unknown>): Promise<number> {
    const sql = `insert into ${tableName} set ?`;
    const result = await pool.query(sql, objSet);
    return (result[0] as { insertId: number }).insertId;
  }

  async function update(tableName: string, objSet: Record<string, unknown>, objWhere: WhereParams): Promise<unknown> {
    const sqlWhere = pool.escape(objWhere).replace(/,/g, ' and');
    let sql = `update \`${tableName}\` set ?`;
    if (sqlWhere && sqlWhere.length > 0) sql = `${sql} where ${sqlWhere}`;
    return pool.query(sql, objSet);
  }

  async function save(tableName: string, objSet: Record<string, unknown>): Promise<number> {
    if (objSet.id) {
      const row = await selectOne(tableName, { id: objSet.id } as WhereParams);
      if (row) {
        await update(tableName, objSet, { id: objSet.id } as WhereParams);
        return objSet.id as number;
      }
    }
    if (objSet.id) delete objSet.id;
    return insert(tableName, objSet);
  }

  async function doTransaction<T>(process: (conn: mysql2.PoolConnection) => Promise<T>): Promise<T> {
    const conn = await pool.getConnection();
    await conn.beginTransaction();
    try {
      const result = await process(conn);
      await conn.commit();
      return result;
    } catch (e) {
      await conn.rollback();
      throw e;
    } finally {
      conn.release();
    }
  }

  return { run, query, selectOne, select, pager, insert, update, save, doTransaction };
}

export type Mysql = ReturnType<typeof createMysql>;
export { createMysql };

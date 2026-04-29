import OSS from 'ali-oss';
import path from 'path';
import fs from 'fs';
import mime from 'mime';

function httpCache(extname: string, htmlDown = false): Record<string, string> {
  let maxAge = 70 * 365 * 24 * 60 * 60;
  const now = Date.now();
  const headers: Record<string, string> = {
    'Cache-Control': `max-age=${maxAge}`,
    Expires: new Date(now + maxAge * 1000).toUTCString(),
    'Last-Modified': new Date().toUTCString(),
    'Content-Type': mime.getType(extname) || 'application/octet-stream',
  };

  if (extname === '.html' || extname === '.js' || extname === '.css') {
    maxAge = 30 * 24 * 60 * 60;
    headers['Cache-Control'] = `max-age=${maxAge}`;
    headers['Expires'] = new Date(now + maxAge * 1000).toUTCString();
  }
  if (extname === '.pdf' || htmlDown) {
    headers['Content-Type'] = 'application/force-download';
    headers['Content-Disposition'] = 'attachment;';
  }
  return headers;
}

function createOssClient(opts: Partial<OSS.Options> & { bucket: string }): OSS {
  return new OSS({
    accessKeyId: process.env.ALIYUN_OSS_ACCESS_KEY_ID || '',
    accessKeySecret: process.env.ALIYUN_OSS_ACCESS_KEY_SECRET || '',
    bucket: opts.bucket,
    region: process.env.ALIYUN_OSS_REGION || 'oss-cn-beijing',
    timeout: 3000 * 1000,
    endpoint: process.env.ALIYUN_OSS_ENDPOINT,
  });
}

const OSS_CLIENT = createOssClient({ bucket: process.env.ALIYUN_OSS_BUCKET || '' });
const VIDEO_OSS_CLIENT = createOssClient({ bucket: process.env.ALIYUN_OSS_VIDEO_BUCKET || '' });
const AUDIO_OSS_CLIENT = createOssClient({ bucket: process.env.ALIYUN_OSS_AUDIO_BUCKET || '' });

async function upload(filename: string, filepath: string, htmlDown = false): Promise<OSS.ObjectMeta | null> {
  try {
    const result = await OSS_CLIENT.put(filename, fs.createReadStream(filepath), {
      headers: httpCache(path.extname(filename), htmlDown),
    });
    return result;
  } catch (e) {
    console.error(e);
  }
  return null;
}

async function videoUpload(filename: string, filepath: string, htmlDown = false): Promise<OSS.ObjectMeta | null> {
  try {
    return await VIDEO_OSS_CLIENT.put(filename, fs.createReadStream(filepath), {
      headers: httpCache(path.extname(filename), htmlDown),
    });
  } catch (e) {
    console.error(e);
  }
  return null;
}

async function audioUpload(filename: string, filepath: string, htmlDown = false): Promise<OSS.ObjectMeta | null> {
  try {
    return await AUDIO_OSS_CLIENT.put(filename, fs.createReadStream(filepath), {
      headers: httpCache(path.extname(filename), htmlDown),
    });
  } catch (e) {
    console.error(e);
  }
  return null;
}

async function download(
  source: string | string[],
  target: string,
): Promise<void> {
  const sources = Array.isArray(source) ? source : [source];
  if (sources.length === 0) return;
  await Promise.all(
    sources.map((key) => OSS_CLIENT.get(key, path.join(target, path.basename(key)))),
  );
}

async function isHaveFile(filename: string): Promise<boolean> {
  const result = await OSS_CLIENT.list({ prefix: filename });
  return !!(result.objects && result.objects.length > 0);
}

async function downloadOne(objectKey: string): Promise<OSS.GetStreamResult> {
  return await OSS_CLIENT.getStream(objectKey);
}

async function downloadLocal(filename: string, localfile: string): Promise<OSS.ObjectMeta> {
  return await OSS_CLIENT.get(filename, localfile);
}

async function mv(source: string, target: string): Promise<void> {
  await OSS_CLIENT.copy(target, source);
  await OSS_CLIENT.delete(source);
}

export const oss = {
  upload,
  videoUpload,
  audioUpload,
  download,
  downloadOne,
  downloadLocal,
  isHaveFile,
  mv,
};

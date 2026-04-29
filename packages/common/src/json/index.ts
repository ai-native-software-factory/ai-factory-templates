export function isObject(target: unknown): boolean {
  return (
    typeof target === 'object' &&
    Object.prototype.toString.call(target).toLowerCase() === '[object object]' &&
    !Array.isArray(target)
  );
}

export function isArray(target: unknown): boolean {
  return Object.prototype.toString.call(target) === '[object Array]';
}

export function parseUrls(mainObj: unknown): Set<string> {
  const urlSet = new Set<string>();

  function parse(obj: unknown): null {
    if (!isObject(obj) && !isArray(obj)) {
      return obj;
    }

    if (isArray(obj)) {
      for (const item of obj) {
        parse(item);
      }
    } else if (isObject(obj)) {
      const record = obj as Record<string, unknown>;
      for (const key of Object.keys(record)) {
        parse(record[key]);
      }
    }
    return null;
  }

  parse(mainObj);
  return urlSet;
}

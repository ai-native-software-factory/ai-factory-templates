function getNowDate(): string {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const strDate = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${strDate}`;
}

export function isDuringDate(beginDateStr: string, endDateStr: string): boolean {
  const curDate = new Date(getNowDate());
  const beginDate = new Date(beginDateStr);
  const endDate = new Date(endDateStr);
  return curDate >= beginDate && curDate <= endDate;
}

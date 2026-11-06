export function paginate(items, page, pageSize) {
  if (!Number.isInteger(page) || page < 1) throw new Error("page must be >= 1");
  if (!Number.isInteger(pageSize) || pageSize < 1) throw new Error("pageSize must be >= 1");
  const start = (page - 1) * pageSize;
  return {
    items: items.slice(start, start + pageSize),
    total: items.length,
    totalPages: Math.ceil(items.length / pageSize),
  };
}

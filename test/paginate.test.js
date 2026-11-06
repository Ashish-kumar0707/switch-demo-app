import { test } from "node:test";
import assert from "node:assert";
import { paginate } from "../src/paginate.js";

const data = Array.from({ length: 25 }, (_, i) => i + 1);

test("first page", () => assert.deepEqual(paginate(data, 1, 10).items, data.slice(0, 10)));
test("last partial page", () => assert.deepEqual(paginate(data, 3, 10).items, [21, 22, 23, 24, 25]));
test("total pages", () => assert.equal(paginate(data, 1, 10).totalPages, 3));
test("rejects page 0", () => assert.throws(() => paginate(data, 0, 10)));

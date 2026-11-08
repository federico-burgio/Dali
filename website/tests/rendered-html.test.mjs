import assert from 'node:assert/strict';
import { readFile, access } from 'node:fs/promises';
import test from 'node:test';

const root = new URL('../out/', import.meta.url);
const pages = new Map(await Promise.all(['', 'docs/'].map(async path => [path, await readFile(new URL(`${path}index.html`, root), 'utf8')])));

test('exported navigation resolves to existing pages and section anchors', async () => {
  for (const [path, html] of pages) {
    for (const [, href] of html.matchAll(/href="([^" ]+)"/g)) {
      if (!href.startsWith('/') && !href.startsWith('#')) continue;
      const url = new URL(href, `https://zonebar.karti.dev/${path}`);
      if (url.pathname.startsWith('/_next/') || /\.[a-z0-9]+$/i.test(url.pathname)) { await access(new URL(url.pathname.slice(1), root)); continue; }
      const target = pages.get(url.pathname.slice(1));
      assert.ok(target, `Missing page: ${href} from /${path}`);
      if (url.hash) assert.ok(target.includes(`id="${url.hash.slice(1)}"`), `Missing anchor: ${href}`);
    }
  }
});

test('both pages include the release download and exported brand assets', async () => {
  for (const html of pages.values()) {
    assert.ok(html.includes('https://github.com/kkz6/ZoneBar/releases/latest/download/ZoneBar.dmg'));
    assert.match(html, /<main[^>]+id="main-content"/);
  }
  await access(new URL('zonebar-icon.png', root));
  await access(new URL('workspace-pattern.png', root));
});

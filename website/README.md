# ZoneBar website

The public website at https://zonebar.karti.dev is statically exported with Next.js and published by GitHub Pages when website changes reach main.

## Develop and verify

Use Node.js 24 or newer:

```sh
npm ci
npm test
npm run lint
npx tsc --noEmit
```

Preview the static output with `python3 -m http.server 4192 --directory out`. `npm run dev` retains the existing local vinext development option.

## Content and design

- `app/page.tsx`: homepage, features, installation, and FAQs.
- `app/docs/page.tsx`: getting-started guide.
- `app/components/SiteChrome.tsx`: shared navigation, latest-release download, and footer.
- `app/components/ClockPreview.tsx`: interactive, client-side timezone demonstration. It never reads a visitor's calendar or app settings.
- `app/globals.css`: ivory, slate, and teal design foundations shared with Morrow, plus the ZoneBar clock preview.

The native app icon is in `public/zonebar-icon.png`. The original linked-path pattern in `public/workspace-pattern.png` is shared with Morrow. Inter Variable and Fraunces Variable are bundled from Fontsource under the SIL Open Font License; Lucide icons are distributed under ISC. The public website does not load fonts from a third-party server.

Download links use the stable `ZoneBar.dmg` asset from the latest signed release. Keep feature and privacy descriptions aligned with the application; optional update checks use the network, and Calendar access requires explicit permission.

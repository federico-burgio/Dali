import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://zonebar.karti.dev"),
  title: "ZoneBar — World clocks, beautifully close",
  alternates: { canonical: "/" },
  description:
    "A lightweight native macOS menu bar app for world clocks and effortless timezone coordination.",
  icons: {
    icon: "/zonebar-icon.png",
    shortcut: "/zonebar-icon.png",
  },
  openGraph: {
    title: "ZoneBar — Your team’s time, right on time",
    description:
      "Native world clocks and effortless timezone coordination, right in your macOS menu bar.",
    type: "website",
    images: [
      {
        url: "/og.png",
        width: 1200,
        height: 630,
        alt: "ZoneBar world clock app for macOS",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ZoneBar — Your team’s time, right on time",
    description: "Native world clocks for macOS.",
    images: ["/og.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        {children}
      </body>
    </html>
  );
}

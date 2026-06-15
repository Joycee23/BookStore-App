import NextAuth from "next-auth";
import GoogleProvider from "next-auth/providers/google";
import EmailProvider from "next-auth/providers/email";
import { PrismaAdapter } from "@auth/prisma-adapter";
import { prisma } from "@/lib/prisma";

const handler = NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID || "GOOGLE_CLIENT_ID",
      clientSecret: process.env.GOOGLE_CLIENT_SECRET || "GOOGLE_CLIENT_SECRET",
    }),
    EmailProvider({
      server: process.env.EMAIL_SERVER || "smtp://username:password@smtp.example.com:587",
      from: process.env.EMAIL_FROM || "noreply@example.com",
    }),
  ],
  pages: {
    signIn: '/admin', // Will use our custom UI in /admin/layout.tsx
  },
  callbacks: {
    async session({ session, user }) {
      if (session.user) {
        session.user.id = user.id;
      }
      return session;
    },
  },
  secret: process.env.NEXTAUTH_SECRET || "fallback_secret_for_development_only",
});

export { handler as GET, handler as POST };

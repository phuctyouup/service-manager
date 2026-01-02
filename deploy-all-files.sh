#!/bin/bash
# FSM Complete Deployment Script
# Writes all final artifacts to proper locations

set -e

ROOT="."

echo "🚀 Deploying FSM complete structure..."

# ============================================
# ROOT CONFIG FILES
# ============================================

cat > "$ROOT/pnpm-workspace.yaml" << 'EOF'
packages:
  - 'apps/*'
  - 'packages/*'
EOF

cat > "$ROOT/turbo.json" << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [".env"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "build/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "type-check": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["^build"]
    },
    "db:generate": {
      "cache": false
    },
    "db:push": {
      "cache": false
    },
    "db:migrate": {
      "cache": false
    },
    "clean": {
      "cache": false
    }
  }
}
EOF

cat > "$ROOT/tsconfig.base.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowJs": true,
    "checkJs": false,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "isolatedModules": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "incremental": true,
    "paths": {
      "@fsm/core": ["./packages/core/src"],
      "@fsm/core/*": ["./packages/core/src/*"],
      "@fsm/db": ["./packages/db/src"],
      "@fsm/db/*": ["./packages/db/src/*"],
      "@fsm/schemas": ["./packages/schemas/src"],
      "@fsm/schemas/*": ["./packages/schemas/src/*"],
      "@fsm/queue": ["./packages/queue/src"],
      "@fsm/queue/*": ["./packages/queue/src/*"],
      "@fsm/storage": ["./packages/storage/src"],
      "@fsm/storage/*": ["./packages/storage/src/*"],
      "@fsm/ai": ["./packages/ai/src"],
      "@fsm/ai/*": ["./packages/ai/src/*"],
      "@fsm/logger": ["./packages/logger/src"],
      "@fsm/logger/*": ["./packages/logger/src/*"]
    }
  },
  "exclude": ["node_modules", "dist", "build", ".next"]
}
EOF

cat > "$ROOT/package.json" << 'EOF'
{
  "name": "fsm",
  "version": "1.0.0",
  "private": true,
  "description": "Field Service Manager - Industry Standard Platform",
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=9.0.0"
  },
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "type-check": "turbo type-check",
    "test": "turbo test",
    "clean": "turbo clean && rm -rf node_modules",
    "db:generate": "turbo db:generate",
    "db:push": "turbo db:push",
    "db:migrate": "turbo db:migrate",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "format:check": "prettier --check \"**/*.{ts,tsx,js,jsx,json,md}\""
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "prettier": "^3.2.4",
    "turbo": "^2.0.0",
    "typescript": "^5.3.3"
  }
}
EOF

# ============================================
# PACKAGE.JSON FILES
# ============================================

mkdir -p "$ROOT/packages/core"
cat > "$ROOT/packages/core/package.json" << 'EOF'
{
  "name": "@fsm/core",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@fsm/db": "workspace:*"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/packages/db"
cat > "$ROOT/packages/db/package.json" << 'EOF'
{
  "name": "@fsm/db",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "type-check": "tsc --noEmit",
    "db:generate": "prisma generate",
    "db:push": "prisma db push",
    "db:migrate": "prisma migrate dev",
    "db:migrate:deploy": "prisma migrate deploy",
    "db:seed": "tsx prisma/seed.ts",
    "db:studio": "prisma studio",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@prisma/client": "^6.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "prisma": "^6.0.0",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/packages/schemas"
cat > "$ROOT/packages/schemas/package.json" << 'EOF'
{
  "name": "@fsm/schemas",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/packages/queue"
cat > "$ROOT/packages/queue/package.json" << 'EOF'
{
  "name": "@fsm/queue",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "bullmq": "^5.0.0",
    "ioredis": "^5.3.2"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/packages/storage"
cat > "$ROOT/packages/storage/package.json" << 'EOF'
{
  "name": "@fsm/storage",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "minio": "^8.0.0"
  },
  "devDependencies": {
    "@types/minio": "^7.1.1",
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/packages/ai"
cat > "$ROOT/packages/ai/package.json" << 'EOF'
{
  "name": "@fsm/ai",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@anthropic-ai/sdk": "^0.27.0",
    "@fsm/core": "workspace:*",
    "@fsm/db": "workspace:*"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/packages/logger"
cat > "$ROOT/packages/logger/package.json" << 'EOF'
{
  "name": "@fsm/logger",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "pino": "^8.17.0",
    "pino-pretty": "^10.3.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/apps/api"
cat > "$ROOT/apps/api/package.json" << 'EOF'
{
  "name": "@fsm/api",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@fsm/core": "workspace:*",
    "@fsm/db": "workspace:*",
    "@fsm/schemas": "workspace:*",
    "@fsm/logger": "workspace:*",
    "express": "^4.18.2",
    "express-async-errors": "^3.1.1",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "zod": "^3.22.4",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/bcryptjs": "^2.4.6",
    "@types/node": "^20.11.0",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/apps/worker"
cat > "$ROOT/apps/worker/package.json" << 'EOF'
{
  "name": "@fsm/worker",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@fsm/core": "workspace:*",
    "@fsm/db": "workspace:*",
    "@fsm/queue": "workspace:*",
    "@fsm/storage": "workspace:*",
    "@fsm/ai": "workspace:*",
    "@fsm/logger": "workspace:*",
    "pdf-parse": "^1.1.1",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "@types/pdf-parse": "^1.1.4",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3"
  }
}
EOF

mkdir -p "$ROOT/apps/web"
cat > "$ROOT/apps/web/package.json" << 'EOF'
{
  "name": "@fsm/web",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@fsm/schemas": "workspace:*",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/react": "^18.2.47",
    "@types/react-dom": "^18.2.18",
    "@vitejs/plugin-react": "^4.2.1",
    "typescript": "^5.3.3",
    "vite": "^5.0.11"
  }
}
EOF

# ============================================
# CORE CONTEXT FILES
# ============================================

mkdir -p "$ROOT/packages/core/src/context"

cat > "$ROOT/packages/core/src/context/RequestContext.ts" << 'EOF'
// FSM/packages/core/src/context/RequestContext.ts

import { UserRole } from "@prisma/client";

export type RequestContext = {
  requestId: string;
  actor: {
    id: string;
    role: UserRole;
    type: "human" | "system" | "ai";
  };
  source: "api" | "worker" | "cron" | "betty";
  timestamp: Date;
};
EOF

cat > "$ROOT/packages/core/src/context/createContext.ts" << 'EOF'
// FSM/packages/core/src/context/createContext.ts

import { RequestContext } from "./RequestContext";
import { UserRole } from "@prisma/client";

type CreateContextInput = {
  actorId: string;
  role: UserRole;
  source: "api" | "worker" | "cron" | "betty";
  requestId?: string;
};

export function createContext(input: CreateContextInput): RequestContext {
  const { actorId, role, source, requestId } = input;

  // Determine actor type based on source and actorId
  let actorType: "human" | "system" | "ai";

  if (source === "betty") {
    actorType = "ai";
  } else if (source === "cron" || actorId === "system") {
    actorType = "system";
  } else {
    actorType = "human";
  }

  return {
    requestId: requestId || crypto.randomUUID(),
    actor: {
      id: actorId,
      role,
      type: actorType,
    },
    source,
    timestamp: new Date(),
  };
}

// Convenience factory for Betty calls
export function createBettyContext(conversationId?: string): RequestContext {
  return createContext({
    actorId: "betty-ai",
    role: "ADMIN", // Betty has elevated permissions
    source: "betty",
    requestId: conversationId,
  });
}

// Convenience factory for system/cron jobs
export function createSystemContext(jobName: string): RequestContext {
  return createContext({
    actorId: "system",
    role: "ADMIN",
    source: "cron",
    requestId: `cron-${jobName}-${Date.now()}`,
  });
}
EOF

# ============================================
# CORE DOMAIN FILES
# ============================================

mkdir -p "$ROOT/packages/core/src/domain"

cat > "$ROOT/packages/core/src/domain/Account.ts" << 'EOF'
// FSM/packages/core/src/domain/Account.ts

import { AccountStatus, AccountType } from "@prisma/client";

export type Account = {
  id: string;
  accountNumber: string;
  status: AccountStatus;
  type: AccountType;
  taxExempt: boolean;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string | null;
};

export type AccountWithContacts = Account & {
  customers: Array<{
    id: string;
    firstName: string;
    lastName: string;
    isPrimary: boolean;
  }>;
  emails: Array<{
    id: string;
    email: string;
    isPrimary: boolean;
  }>;
  phoneNumbers: Array<{
    id: string;
    number: string;
    isPrimary: boolean;
  }>;
  addresses: Array<{
    id: string;
    street1: string;
    city: string;
    state: string;
    zipCode: string;
    isPrimary: boolean;
  }>;
};
EOF

cat > "$ROOT/packages/core/src/domain/Job.ts" << 'EOF'
// FSM/packages/core/src/domain/Job.ts

import { JobStatus } from "@prisma/client";

export type Job = {
  id: string;
  estimateId: string | null;
  accountId: string;
  csrId: string;
  title: string;
  description: string | null;
  status: JobStatus;
  createdAt: Date;
  updatedAt: Date;
};

export type JobWithDetails = Job & {
  account: {
    id: string;
    accountNumber: string;
  };
  visits: Array<{
    id: string;
    technicianId: string;
    startTime: Date;
    endTime: Date;
  }>;
  notes: Array<{
    id: string;
    content: string;
    createdAt: Date;
  }>;
};
EOF

cat > "$ROOT/packages/core/src/domain/Visit.ts" << 'EOF'
// FSM/packages/core/src/domain/Visit.ts

export type Visit = {
  id: string;
  jobId: string;
  technicianId: string;
  startTime: Date;
  endTime: Date;
  summary: string | null;
};

export type VisitWithContext = Visit & {
  job: {
    id: string;
    title: string;
    accountId: string;
  };
  technician: {
    id: string;
    name: string;
  };
};
EOF

cat > "$ROOT/packages/core/src/domain/User.ts" << 'EOF'
// FSM/packages/core/src/domain/User.ts

import { UserRole } from "@prisma/client";

export type User = {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  isActive: boolean;
  createdAt: Date;
};

export type UserCapabilities = {
  canCreateEstimates: boolean;
  canApproveEstimates: boolean;
  canManageJobs: boolean;
  canViewAllAccounts: boolean;
  canAssignTechnicians: boolean;
  canAccessBetty: boolean;
};
EOF

# ============================================
# CORE SERVICES
# ============================================

mkdir -p "$ROOT/packages/core/src/services"

cat > "$ROOT/packages/core/src/services/accountService.ts" << 'EOF'
// FSM/packages/core/src/services/accountService.ts

import { RequestContext } from "../context/RequestContext";
import { Account, AccountWithContacts } from "../domain/Account";
import { PrismaClient, AccountStatus, AccountType } from "@prisma/client";

export class AccountService {
  constructor(private db: PrismaClient) {}

  async getAccount(
    ctx: RequestContext,
    accountId: string
  ): Promise<AccountWithContacts | null> {
    // Authorization check
    this.requireCapability(ctx, "canViewAccounts");

    return this.db.account.findUnique({
      where: { id: accountId },
      include: {
        customers: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            isPrimary: true,
          },
        },
        emails: {
          select: {
            id: true,
            email: true,
            isPrimary: true,
          },
        },
        phoneNumbers: {
          select: {
            id: true,
            number: true,
            isPrimary: true,
          },
        },
        addresses: {
          select: {
            id: true,
            street1: true,
            city: true,
            state: true,
            zipCode: true,
            isPrimary: true,
          },
        },
      },
    });
  }

  async createAccount(
    ctx: RequestContext,
    data: {
      type: AccountType;
      taxExempt?: boolean;
      customer: {
        firstName: string;
        lastName: string;
      };
      email: string;
      phone: string;
      address: {
        street1: string;
        city: string;
        state: string;
        zipCode: string;
      };
    }
  ): Promise<Account> {
    this.requireCapability(ctx, "canCreateAccounts");

    const accountNumber = await this.generateAccountNumber();

    const account = await this.db.account.create({
      data: {
        accountNumber,
        type: data.type,
        taxExempt: data.taxExempt ?? false,
        status: AccountStatus.ACTIVE,
        createdBy: ctx.actor.id,
        customers: {
          create: {
            firstName: data.customer.firstName,
            lastName: data.customer.lastName,
            isPrimary: true,
          },
        },
        emails: {
          create: {
            email: data.email,
            isPrimary: true,
          },
        },
        phoneNumbers: {
          create: {
            number: data.phone,
            isPrimary: true,
          },
        },
        addresses: {
          create: {
            ...data.address,
            isPrimary: true,
          },
        },
      },
    });

    // Emit event for downstream processing
    await this.emitEvent(ctx, "account.created", { accountId: account.id });

    return account;
  }

  async updateAccountStatus(
    ctx: RequestContext,
    accountId: string,
    status: AccountStatus
  ): Promise<Account> {
    this.requireCapability(ctx, "canManageAccounts");

    const account = await this.db.account.update({
      where: { id: accountId },
      data: { status },
    });

    await this.emitEvent(ctx, "account.status_changed", {
      accountId,
      status,
    });

    return account;
  }

  private async generateAccountNumber(): Promise<string> {
    const count = await this.db.account.count();
    return `ACC-${String(count + 1).padStart(5, "0")}`;
  }

  private requireCapability(ctx: RequestContext, capability: string): void {
    // Capability check logic goes here
    // Will be implemented with authorization module
  }

  private async emitEvent(
    ctx: RequestContext,
    eventType: string,
    payload: any
  ): Promise<void> {
    // Event emission logic goes here
    // Will be implemented with events module
  }
}
EOF

cat > "$ROOT/packages/core/src/services/jobService.ts" << 'EOF'
// FSM/packages/core/src/services/jobService.ts

import { RequestContext } from "../context/RequestContext";
import { Job, JobWithDetails } from "../domain/Job";
import { PrismaClient, JobStatus } from "@prisma/client";

export class JobService {
  constructor(private db: PrismaClient) {}

  async getJob(
    ctx: RequestContext,
    jobId: string
  ): Promise<JobWithDetails | null> {
    this.requireCapability(ctx, "canViewJobs");

    return this.db.job.findUnique({
      where: { id: jobId },
      include: {
        account: {
          select: {
            id: true,
            accountNumber: true,
          },
        },
        visits: {
          select: {
            id: true,
            technicianId: true,
            startTime: true,
            endTime: true,
          },
        },
        notes: {
          select: {
            id: true,
            content: true,
            createdAt: true,
          },
          orderBy: {
        startTime: "asc",
      },
    });
  }

  async completeVisit(
    ctx: RequestContext,
    visitId: string,
    summary: string
  ): Promise<void> {
    this.requireCapability(ctx, "canCompleteVisits");

    await this.db.visit.update({
      where: { id: visitId },
      data: { summary },
    });

    await this.emitEvent(ctx, "visit.completed", { visitId });
  }

  private async checkTechnicianAvailability(
    technicianId: string,
    startTime: Date,
    endTime: Date
  ): Promise<boolean> {
    const conflicts = await this.db.visit.count({
      where: {
        technicianId,
        OR: [
          {
            AND: [
              { startTime: { lte: startTime } },
              { endTime: { gt: startTime } },
            ],
          },
          {
            AND: [
              { startTime: { lt: endTime } },
              { endTime: { gte: endTime } },
            ],
          },
          {
            AND: [
              { startTime: { gte: startTime } },
              { endTime: { lte: endTime } },
            ],
          },
        ],
      },
    });

    return conflicts > 0;
  }

  private requireCapability(ctx: RequestContext, capability: string): void {
    // Capability check logic
  }

  private async emitEvent(
    ctx: RequestContext,
    eventType: string,
    payload: any
  ): Promise<void> {
    // Event emission logic
  }
}
EOF

# ============================================
# CORE ERRORS
# ============================================

mkdir -p "$ROOT/packages/core/src/errors"

cat > "$ROOT/packages/core/src/errors/DomainError.ts" << 'EOF'
// FSM/packages/core/src/errors/DomainError.ts

export class DomainError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 400,
    public details?: Record<string, any>
  ) {
    super(message);
    this.name = "DomainError";
    Object.setPrototypeOf(this, DomainError.prototype);
  }

  toJSON() {
    return {
      name: this.name,
      message: this.message,
      code: this.code,
      details: this.details,
    };
  }
}
EOF

cat > "$ROOT/packages/core/src/errors/AuthorizationError.ts" << 'EOF'
// FSM/packages/core/src/errors/AuthorizationError.ts

import { DomainError } from "./DomainError";

export class AuthorizationError extends DomainError {
  constructor(
    message: string = "Insufficient permissions",
    details?: {
      required?: string;
      actor?: string;
      resource?: string;
    }
  ) {
    super(message, "AUTHORIZATION_ERROR", 403, details);
    this.name = "AuthorizationError";
    Object.setPrototypeOf(this, AuthorizationError.prototype);
  }

  static missingCapability(capability: string, actorId: string) {
    return new AuthorizationError("Missing required capability", {
      required: capability,
      actor: actorId,
    });
  }

  static resourceAccess(resourceType: string, resourceId: string) {
    return new AuthorizationError("Cannot access resource", {
      resource: `${resourceType}:${resourceId}`,
    });
  }
}
EOF

cat > "$ROOT/packages/core/src/errors/ConflictError.ts" << 'EOF'
// FSM/packages/core/src/errors/ConflictError.ts

import { DomainError } from "./DomainError";

export class ConflictError extends DomainError {
  constructor(
    message: string = "Resource conflict detected",
    details?: {
      resource?: string;
      expectedVersion?: number;
      actualVersion?: number;
      conflictType?: string;
    }
  ) {
    super(message, "CONFLICT_ERROR", 409, details);
    this.name = "ConflictError";
    Object.setPrototypeOf(this, ConflictError.prototype);
  }

  static versionMismatch(
    resourceType: string,
    resourceId: string,
    expected: number,
    actual: number
  ) {
    return new ConflictError("Version mismatch - resource was modified", {
      resource: `${resourceType}:${resourceId}`,
      expectedVersion: expected,
      actualVersion: actual,
      conflictType: "version",
    });
  }

  static duplicateResource(resourceType: string, identifier: string) {
    return new ConflictError("Resource already exists", {
      resource: `${resourceType}:${identifier}`,
      conflictType: "duplicate",
    });
  }

  static scheduleConflict(
    technicianId: string,
    startTime: Date,
    endTime: Date
  ) {
    return new ConflictError("Schedule conflict detected", {
      resource: `technician:${technicianId}`,
      conflictType: "schedule",
      details: { startTime, endTime },
    });
  }
}
EOF

# ============================================
# CORE EVENTS
# ============================================

mkdir -p "$ROOT/packages/core/src/events"

cat > "$ROOT/packages/core/src/events/Event.ts" << 'EOF'
// FSM/packages/core/src/events/Event.ts

import { RequestContext } from "../context/RequestContext";

export type DomainEvent = {
  id: string;
  type: string;
  timestamp: Date;
  context: RequestContext;
  payload: Record<string, any>;
};

export type EventHandler = (event: DomainEvent) => Promise<void>;

export class EventEmitter {
  private handlers: Map<string, EventHandler[]> = new Map();

  on(eventType: string, handler: EventHandler): void {
    const existing = this.handlers.get(eventType) || [];
    this.handlers.set(eventType, [...existing, handler]);
  }

  async emit(
    ctx: RequestContext,
    eventType: string,
    payload: Record<string, any>
  ): Promise<void> {
    const event: DomainEvent = {
      id: crypto.randomUUID(),
      type: eventType,
      timestamp: new Date(),
      context: ctx,
      payload,
    };

    const handlers = this.handlers.get(eventType) || [];
    await Promise.all(handlers.map((handler) => handler(event)));
  }
}
EOF

# ============================================
# API MIDDLEWARE
# ============================================

mkdir -p "$ROOT/apps/api/src/middleware"

cat > "$ROOT/apps/api/src/middleware/requestContext.ts" << 'EOF'
// FSM/apps/api/src/middleware/requestContext.ts

import { Request, Response, NextFunction } from "express";
import { createContext } from "@fsm/core/context/createContext";
import { RequestContext } from "@fsm/core/context/RequestContext";
import { UserRole } from "@prisma/client";

declare global {
  namespace Express {
    interface Request {
      context: RequestContext;
      user?: {
        id: string;
        role: UserRole;
      };
    }
  }
}

export function attachRequestContext(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  // Extract from auth middleware (assumes auth runs first)
  const actorId = req.user?.id || "anonymous";
  const role = req.user?.role || UserRole.CSR;

  // Extract request ID from header or generate
  const requestId =
    (req.headers["x-request-id"] as string) || crypto.randomUUID();

  // Create context via core factory
  req.context = createContext({
    actorId,
    role,
    source: "api",
    requestId,
  });

  // Add request ID to response headers for tracing
  res.setHeader("X-Request-ID", req.context.requestId);

  next();
}
EOF

# ============================================
# API ROUTES
# ============================================

mkdir -p "$ROOT/apps/api/src/routes"

cat > "$ROOT/apps/api/src/routes/accounts.ts" << 'EOF'
// FSM/apps/api/src/routes/accounts.ts

import { Router } from "express";
import { AccountService } from "@fsm/core/services/accountService";
import { db } from "@fsm/db";
import { z } from "zod";

const router = Router();
const accountService = new AccountService(db);

// GET /accounts/:id
router.get("/:id", async (req, res, next) => {
  try {
    const account = await accountService.getAccount(
      req.context,
      req.params.id
    );

    if (!account) {
      return res.status(404).json({ error: "Account not found" });
    }

    res.json(account);
  } catch (error) {
    next(error);
  }
});

// POST /accounts
router.post("/", async (req, res, next) => {
  try {
    const schema = z.object({
      type: z.enum(["RESIDENTIAL", "COMMERCIAL", "PROPERTY_MANAGEMENT"]),
      taxExempt: z.boolean().optional(),
      customer: z.object({
        firstName: z.string(),
        lastName: z.string(),
      }),
      email: z.string().email(),
      phone: z.string(),
      address: z.object({
        street1: z.string(),
        city: z.string(),
        state: z.string(),
        zipCode: z.string(),
      }),
    });

    const data = schema.parse(req.body);
    const account = await accountService.createAccount(req.context, data);

    res.status(201).json(account);
  } catch (error) {
    next(error);
  }
});

// PATCH /accounts/:id/status
router.patch("/:id/status", async (req, res, next) => {
  try {
    const schema = z.object({
      status: z.enum(["ACTIVE", "INACTIVE", "SUSPENDED", "CLOSED"]),
    });

    const { status } = schema.parse(req.body);
    const account = await accountService.updateAccountStatus(
      req.context,
      req.params.id,
      status
    );

    res.json(account);
  } catch (error) {
    next(error);
  }
});

export default router;
EOF

echo ""
echo "✅ All files deployed successfully!"
echo ""
echo "Next steps:"
echo "1. Run: chmod +x deploy-all-files.sh"
echo "2. Run: ./deploy-all-files.sh"
echo "3. Run: pnpm install"
echo "4. Copy your Prisma schema to packages/db/prisma/schema.prisma"
echo "5. Run: pnpm db:generate" {
            createdAt: "desc",
          },
        },
      },
    });
  }

  async createJob(
    ctx: RequestContext,
    data: {
      accountId: string;
      estimateId?: string;
      title: string;
      description?: string;
    }
  ): Promise<Job> {
    this.requireCapability(ctx, "canCreateJobs");

    const job = await this.db.job.create({
      data: {
        accountId: data.accountId,
        estimateId: data.estimateId,
        title: data.title,
        description: data.description,
        csrId: ctx.actor.id,
        status: JobStatus.TICKET_CREATED,
      },
    });

    await this.emitEvent(ctx, "job.created", { jobId: job.id });

    return job;
  }

  async updateJobStatus(
    ctx: RequestContext,
    jobId: string,
    status: JobStatus,
    version?: number
  ): Promise<Job> {
    this.requireCapability(ctx, "canManageJobs");

    // Concurrency check
    if (version !== undefined) {
      const current = await this.db.job.findUnique({
        where: { id: jobId },
        select: { updatedAt: true },
      });

      if (!current) {
        throw new Error("Job not found");
      }

      // Version mismatch check would go here
    }

    const job = await this.db.job.update({
      where: { id: jobId },
      data: { status },
    });

    await this.emitEvent(ctx, "job.status_changed", { jobId, status });

    return job;
  }

  async addNote(
    ctx: RequestContext,
    jobId: string,
    content: string
  ): Promise<void> {
    this.requireCapability(ctx, "canAddNotes");

    await this.db.note.create({
      data: {
        jobId,
        authorId: ctx.actor.id,
        content,
      },
    });

    await this.emitEvent(ctx, "job.note_added", { jobId });
  }

  private requireCapability(ctx: RequestContext, capability: string): void {
    // Capability check logic
  }

  private async emitEvent(
    ctx: RequestContext,
    eventType: string,
    payload: any
  ): Promise<void> {
    // Event emission logic
  }
}
EOF

cat > "$ROOT/packages/core/src/services/scheduleService.ts" << 'EOF'
// FSM/packages/core/src/services/scheduleService.ts

import { RequestContext } from "../context/RequestContext";
import { PrismaClient } from "@prisma/client";

export class ScheduleService {
  constructor(private db: PrismaClient) {}

  async createVisit(
    ctx: RequestContext,
    data: {
      jobId: string;
      technicianId: string;
      startTime: Date;
      endTime: Date;
    }
  ): Promise<void> {
    this.requireCapability(ctx, "canScheduleVisits");

    // Check technician availability
    const conflict = await this.checkTechnicianAvailability(
      data.technicianId,
      data.startTime,
      data.endTime
    );

    if (conflict) {
      throw new Error("Technician has conflicting appointment");
    }

    await this.db.visit.create({
      data: {
        jobId: data.jobId,
        technicianId: data.technicianId,
        startTime: data.startTime,
        endTime: data.endTime,
      },
    });

    await this.emitEvent(ctx, "visit.scheduled", {
      jobId: data.jobId,
      technicianId: data.technicianId,
    });
  }

  async getUpcomingVisits(
    ctx: RequestContext,
    technicianId?: string
  ): Promise<any[]> {
    this.requireCapability(ctx, "canViewSchedule");

    const where: any = {
      startTime: {
        gte: new Date(),
      },
    };

    if (technicianId) {
      where.technicianId = technicianId;
    }

    return this.db.visit.findMany({
      where,
      include: {
        job: {
          include: {
            account: {
              select: {
                accountNumber: true,
                addresses: {
                  where: { isPrimary: true },
                },
              },
            },
          },
        },
        technician: {
          select: {
            id: true,
            name: true,
          },
        },
      },
      orderBy:

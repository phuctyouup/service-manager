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

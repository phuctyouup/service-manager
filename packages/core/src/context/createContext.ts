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

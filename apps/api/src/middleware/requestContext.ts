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

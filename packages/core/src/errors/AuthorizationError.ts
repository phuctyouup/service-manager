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

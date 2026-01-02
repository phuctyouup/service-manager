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

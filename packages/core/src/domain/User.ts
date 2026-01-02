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

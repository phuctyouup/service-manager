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

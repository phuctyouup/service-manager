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

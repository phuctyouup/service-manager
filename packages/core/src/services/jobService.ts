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

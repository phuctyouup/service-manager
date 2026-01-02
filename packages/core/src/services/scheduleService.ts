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

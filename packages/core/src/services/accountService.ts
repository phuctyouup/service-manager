// FSM/packages/core/src/services/accountService.ts

import { RequestContext } from "../context/RequestContext";
import { Account, AccountWithContacts } from "../domain/Account";
import { PrismaClient, AccountStatus, AccountType } from "@prisma/client";

export class AccountService {
  constructor(private db: PrismaClient) {}

  async getAccount(
    ctx: RequestContext,
    accountId: string
  ): Promise<AccountWithContacts | null> {
    // Authorization check
    this.requireCapability(ctx, "canViewAccounts");

    return this.db.account.findUnique({
      where: { id: accountId },
      include: {
        customers: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            isPrimary: true,
          },
        },
        emails: {
          select: {
            id: true,
            email: true,
            isPrimary: true,
          },
        },
        phoneNumbers: {
          select: {
            id: true,
            number: true,
            isPrimary: true,
          },
        },
        addresses: {
          select: {
            id: true,
            street1: true,
            city: true,
            state: true,
            zipCode: true,
            isPrimary: true,
          },
        },
      },
    });
  }

  async createAccount(
    ctx: RequestContext,
    data: {
      type: AccountType;
      taxExempt?: boolean;
      customer: {
        firstName: string;
        lastName: string;
      };
      email: string;
      phone: string;
      address: {
        street1: string;
        city: string;
        state: string;
        zipCode: string;
      };
    }
  ): Promise<Account> {
    this.requireCapability(ctx, "canCreateAccounts");

    const accountNumber = await this.generateAccountNumber();

    const account = await this.db.account.create({
      data: {
        accountNumber,
        type: data.type,
        taxExempt: data.taxExempt ?? false,
        status: AccountStatus.ACTIVE,
        createdBy: ctx.actor.id,
        customers: {
          create: {
            firstName: data.customer.firstName,
            lastName: data.customer.lastName,
            isPrimary: true,
          },
        },
        emails: {
          create: {
            email: data.email,
            isPrimary: true,
          },
        },
        phoneNumbers: {
          create: {
            number: data.phone,
            isPrimary: true,
          },
        },
        addresses: {
          create: {
            ...data.address,
            isPrimary: true,
          },
        },
      },
    });

    // Emit event for downstream processing
    await this.emitEvent(ctx, "account.created", { accountId: account.id });

    return account;
  }

  async updateAccountStatus(
    ctx: RequestContext,
    accountId: string,
    status: AccountStatus
  ): Promise<Account> {
    this.requireCapability(ctx, "canManageAccounts");

    const account = await this.db.account.update({
      where: { id: accountId },
      data: { status },
    });

    await this.emitEvent(ctx, "account.status_changed", {
      accountId,
      status,
    });

    return account;
  }

  private async generateAccountNumber(): Promise<string> {
    const count = await this.db.account.count();
    return `ACC-${String(count + 1).padStart(5, "0")}`;
  }

  private requireCapability(ctx: RequestContext, capability: string): void {
    // Capability check logic goes here
    // Will be implemented with authorization module
  }

  private async emitEvent(
    ctx: RequestContext,
    eventType: string,
    payload: any
  ): Promise<void> {
    // Event emission logic goes here
    // Will be implemented with events module
  }
}

// FSM/packages/core/src/domain/Account.ts

import { AccountStatus, AccountType } from "@prisma/client";

export type Account = {
  id: string;
  accountNumber: string;
  status: AccountStatus;
  type: AccountType;
  taxExempt: boolean;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string | null;
};

export type AccountWithContacts = Account & {
  customers: Array<{
    id: string;
    firstName: string;
    lastName: string;
    isPrimary: boolean;
  }>;
  emails: Array<{
    id: string;
    email: string;
    isPrimary: boolean;
  }>;
  phoneNumbers: Array<{
    id: string;
    number: string;
    isPrimary: boolean;
  }>;
  addresses: Array<{
    id: string;
    street1: string;
    city: string;
    state: string;
    zipCode: string;
    isPrimary: boolean;
  }>;
};

// FSM/apps/api/src/routes/accounts.ts

import { Router } from "express";
import { AccountService } from "@fsm/core/services/accountService";
import { db } from "@fsm/db";
import { z } from "zod";

const router = Router();
const accountService = new AccountService(db);

// GET /accounts/:id
router.get("/:id", async (req, res, next) => {
  try {
    const account = await accountService.getAccount(
      req.context,
      req.params.id
    );

    if (!account) {
      return res.status(404).json({ error: "Account not found" });
    }

    res.json(account);
  } catch (error) {
    next(error);
  }
});

// POST /accounts
router.post("/", async (req, res, next) => {
  try {
    const schema = z.object({
      type: z.enum(["RESIDENTIAL", "COMMERCIAL", "PROPERTY_MANAGEMENT"]),
      taxExempt: z.boolean().optional(),
      customer: z.object({
        firstName: z.string(),
        lastName: z.string(),
      }),
      email: z.string().email(),
      phone: z.string(),
      address: z.object({
        street1: z.string(),
        city: z.string(),
        state: z.string(),
        zipCode: z.string(),
      }),
    });

    const data = schema.parse(req.body);
    const account = await accountService.createAccount(req.context, data);

    res.status(201).json(account);
  } catch (error) {
    next(error);
  }
});

// PATCH /accounts/:id/status
router.patch("/:id/status", async (req, res, next) => {
  try {
    const schema = z.object({
      status: z.enum(["ACTIVE", "INACTIVE", "SUSPENDED", "CLOSED"]),
    });

    const { status } = schema.parse(req.body);
    const account = await accountService.updateAccountStatus(
      req.context,
      req.params.id,
      status
    );

    res.json(account);
  } catch (error) {
    next(error);
  }
});

export default router;

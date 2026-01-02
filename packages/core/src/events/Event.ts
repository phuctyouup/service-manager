// FSM/packages/core/src/events/Event.ts

import { RequestContext } from "../context/RequestContext";

export type DomainEvent = {
  id: string;
  type: string;
  timestamp: Date;
  context: RequestContext;
  payload: Record<string, any>;
};

export type EventHandler = (event: DomainEvent) => Promise<void>;

export class EventEmitter {
  private handlers: Map<string, EventHandler[]> = new Map();

  on(eventType: string, handler: EventHandler): void {
    const existing = this.handlers.get(eventType) || [];
    this.handlers.set(eventType, [...existing, handler]);
  }

  async emit(
    ctx: RequestContext,
    eventType: string,
    payload: Record<string, any>
  ): Promise<void> {
    const event: DomainEvent = {
      id: crypto.randomUUID(),
      type: eventType,
      timestamp: new Date(),
      context: ctx,
      payload,
    };

    const handlers = this.handlers.get(eventType) || [];
    await Promise.all(handlers.map((handler) => handler(event)));
  }
}

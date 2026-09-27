import { schema, t, type SchemaType } from "@colyseus/schema";

export const Cursor = schema({
  x: t.number().default(0),
  y: t.number().default(0),
  color: t.number().default(0xffffff),
  size: t.number().default(8),
});
export type Cursor = SchemaType<typeof Cursor>;

export const MyRoomState = schema({
  cursors: t.map(Cursor),
});
export type MyRoomState = SchemaType<typeof MyRoomState>;
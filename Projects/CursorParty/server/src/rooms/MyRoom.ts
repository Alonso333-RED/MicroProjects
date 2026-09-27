import { Room, Client, CloseCode } from "colyseus";
import { MyRoomState, Cursor } from "./schema/MyRoomState.js";

function colorAleatorio(): number {
  return Math.floor(Math.random() * 0xffffff);
}
export class MyRoom extends Room<{ state: MyRoomState }> {
  maxClients = 9999;
  state = new MyRoomState();

  messages = {
    move: (client: Client, message: { x: number; y: number }) => {
      const cursor = this.state.cursors.get(client.sessionId);
      if (cursor) {
        cursor.x = message.x;
        cursor.y = message.y;
      }
    },
    click: (client: Client, message: { x: number; y: number }) => {
      const cursor = this.state.cursors.get(client.sessionId);
      this.broadcast("effect", {
        x: message.x,
        y: message.y,
        color: cursor?.color ?? 0xffffff,
      });
    },
  };

  onJoin(client: Client, options: any) {
    console.log(client.sessionId, "joined!");

    const cursor = new Cursor();
    cursor.color = colorAleatorio();
    cursor.size = 6 + Math.random() * 10;
    this.state.cursors.set(client.sessionId, cursor);
  }

  onLeave(client: Client, code: CloseCode) {
    console.log(client.sessionId, "left!", code);
    this.state.cursors.delete(client.sessionId);
  }
}
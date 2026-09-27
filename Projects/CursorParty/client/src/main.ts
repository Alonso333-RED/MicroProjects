import Phaser from "phaser";
import { Client, getStateCallbacks } from "@colyseus/sdk";

class MainScene extends Phaser.Scene {
  async create() {
    const client = new Client("ws://192.168.1.91:2567");
    const room = await client.joinOrCreate("my_room");
    const $ = getStateCallbacks(room);

    $(room.state).cursors.onAdd((cursor: any, sessionId: string) => {
      const circle = this.add.circle(cursor.x, cursor.y, cursor.size, cursor.color);

      $(cursor).onChange(() => {
        circle.setPosition(cursor.x, cursor.y);
      });
    });

    this.input.on("pointermove", (pointer: Phaser.Input.Pointer) => {
      room.send("move", { x: pointer.x, y: pointer.y });
    });

    this.input.on("pointerdown", (pointer: Phaser.Input.Pointer) => {
      room.send("click", { x: pointer.x, y: pointer.y });
    });

    room.onMessage("effect", (data: { x: number; y: number; color: number }) => {
      const efecto = this.add.circle(data.x, data.y, 10, data.color, 0.6);

      this.tweens.add({
        targets: efecto,
        scale: 3,
        alpha: 0,
        duration: 400,
        onComplete: () => efecto.destroy(),
      });
    });
  } // 👈 create() se cierra recién acá, al final de todo
}

new Phaser.Game({
  type: Phaser.AUTO,
  backgroundColor: "#000",
  parent: "app",
  scene: MainScene,
  width: 800,
  height: 600,
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
});
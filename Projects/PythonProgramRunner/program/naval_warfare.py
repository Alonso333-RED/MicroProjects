import time
import random
import copy

print("\nInicializando Naval Warfare...")
print("Hecho por Alonso.")
print("Ver: 1.0.0")

class Battleship:
    def __init__(self, name, maxhull, damage, agility, maxammo, reload, repair):
        self.name = name
        self.maxhull = maxhull
        self.hull = maxhull
        self.damage = damage
        self.agility = agility
        self.maxammo = maxammo
        self.ammo = maxammo
        self.reload = reload
        self.repair = repair

    def stats(self):
        print(f"\n--- Información del buque ---")
        print(f"Nombre: {self.name}")
        print(f"Integridad: {self.maxhull}")
        print(f"Daño potencial: {self.damage}")
        print(f"Agilidad: {self.agility}")
        print(f"Munición: {self.maxammo}")
        print(f"Recarga: {self.reload}")
        print(f"Reparación: {self.repair}\n")

    def state(self):
        print(f"\n--- Estado actual del buque ---")
        print(f"Integridad actual: {self.hull}")
        print(f"Munición actual: {self.ammo}\n")

ships = [
    Battleship("LethalGalleon", 825, 250, 35, 3, 1, 60),
    Battleship("SpeedFish", 325, 125, 75, 5, 2, 60),
    Battleship("NeoCruiser", 700, 150, 50, 6, 2, 70),
    Battleship("IronWhale", 1000, 175, 25, 4, 2, 85),
    Battleship("Floater", 600, 125, 55, 4, 1, 100),
    Battleship("Lancer", 250, 250, 65, 2, 1, 45),
    Battleship("SeaUrchin", 675, 125, 45, 10, 4, 65),
    Battleship("Dreadnought", 900, 200, 20, 2, 1, 60),
    Battleship("Mosquito", 100, 100, 90, 4 ,2, 25),
    Battleship("Spectral", 450, 125, 75, 1, 1, 30),
]

class Player:
    def __init__(self, name):
        self.name = name
        self.ship = None

    def choose_ship(self, ships):
        print(f"\n{self.name}, Elige un barco:")
        for i, ship in enumerate(ships):
            print(f"{i + 1}: {ship.name}")

        while True:
            try:
                choice = int(input("\nSelecciona un barco por su número: ")) - 1
                if 0 <= choice < len(ships):
                    selected_ship = ships[choice]
                    self.ship = Battleship(
                        selected_ship.name, 
                        selected_ship.maxhull, 
                        selected_ship.damage, 
                        selected_ship.agility,
                        selected_ship.maxammo, 
                        selected_ship.reload, 
                        selected_ship.repair
                    )
                    print(f"\n{self.name} ha elegido {self.ship.name}!")
                    break
                else:
                    print("Selección inválida!")
            except ValueError:
                print("Ingresa un número válido!")

    def show_ship(self):
        if self.ship:
            self.ship.stats()
        else:
            print("No barco seleccionado.")
            
    def playing(self, enemy):
        while True:
            print(f"\n{self.name}: Integridad: {self.ship.hull}/{self.ship.maxhull} | Munición: {self.ship.ammo}/{self.ship.maxammo} V/S Enemigo: Integridad: {enemy.ship.hull}/{enemy.ship.maxhull} | Munición: {enemy.ship.ammo}/{enemy.ship.maxammo}")
            print(f"{self.name}, selecciona una acción:")
            print("w: Atacar | d: Recargar | a: Reparar | t: Rendirse")
            act = input("Orden: ").lower()

            if act == "w":
                print("-" * 30)
                time.sleep(0.25)
                print("\nAtacando...")
                time.sleep(0.25)
                self.attack(enemy)
                print()
                time.sleep(0.25)
                enemy.response()
                time.sleep(0.25)
            elif act == "d":
                print("-" * 30)
                time.sleep(0.25)
                print("\nRecargando...")
                time.sleep(0.25)
                self.reload()
                print()
                time.sleep(0.25)
                enemy.response()
                time.sleep(0.25)
            elif act == "a":
                print("-" * 30)
                time.sleep(0.25)
                print("\nReparando...")
                time.sleep(0.25)
                self.repair()
                print()
                time.sleep(0.25)
                enemy.response()
                time.sleep(0.25)
            elif act == "t":
                print("-" * 30)
                time.sleep(0.5)
                print("\nRindiéndose...")
                time.sleep(0.5)
                break
            else:
                print("-" * 30)
                time.sleep(0.5)
                print("Acción no reconocida.")
                time.sleep(0.5)

            if self.ship.hull <= 0:
                print("Tu barco ha sido destruido. ¡Game Over!")
                time.sleep(1)
                break
            elif enemy.ship.hull <= 0:
                print("El barco enemigo ha sido destruido. ¡Has ganado!")
                time.sleep(1)
                break

    def attack(self, enemy):
        if self.ship.ammo > 0:
            print(f"{self.name} ha disparado!")
            self.ship.ammo -= 1
            chance = random.randint(0, 100)
            if chance > enemy.ship.agility:
                damaged = random.randint(0, self.ship.damage)
                enemy.ship.hull -= damaged
                print(f"El ataque ha causado {damaged} de daño!")
                print(f"Integridad del enemigo: {enemy.ship.hull}")
            else:
                print("El ataque ha fallado!")
        else:
            print("No tienes munición disponible!")
        print(f"Munición actual: {self.ship.ammo}")

    def reload(self):
        if self.ship.ammo < self.ship.maxammo:
            print("Recargando munición...")
            self.ship.ammo += self.ship.reload
            if self.ship.ammo > self.ship.maxammo:
                self.ship.ammo = self.ship.maxammo
        else:
            print("Munición llena!")

        print(f"Munición actual: {self.ship.ammo}")
        
    def repair(self):
        if self.ship.hull < self.ship.maxhull:
            print(f"Integridad anterior: {self.ship.hull}")
            repaired = random.randint(0, self.ship.repair)
            self.ship.hull += repaired
            print(f"Reparación: {repaired}")
            if self.ship.hull > self.ship.maxhull:
                self.ship.hull = self.ship.maxhull
        else:
            print("Sin daños!")

        print(f"Integridad del buque: {self.ship.hull}")


class Enemy:
    def __init__(self):
        self.ship = None

    def enemy_select(self, ships):
        enemy_selection = random.choice(ships)
        self.ship = copy.deepcopy(enemy_selection)
        print(f"El enemigo usará un {self.ship.name}!")

    def response(self):
        responses = ["attack", "reload", "repair"]
        response = random.choice(responses)
        
        while True:
            if response == "attack" and self.ship.ammo > 0:
                self.attack()
                break
            elif response == "reload" and self.ship.ammo < self.ship.maxammo:
                self.reload()
                break
            elif response == "repair" and self.ship.hull < self.ship.maxhull:
                self.repair()
                break
            else:
                response = random.choice(responses)

    def attack(self):
        if self.ship.ammo > 0:
            print("El enemigo ha disparado!")
            self.ship.ammo -= 1
            chance = random.randint(0, 100)
            if chance > player.ship.agility:
                damaged = random.randint(0, self.ship.damage)
                player.ship.hull -= damaged
                print(f"El ataque ha provocado {damaged} de daño!")
                print(f"Integridad del jugador: {player.ship.hull}")
            else:
                print("El ataque ha fallado!")
        else:
            print("El enemigo no tiene munición disponible!")

    def reload(self):
        if self.ship.ammo < self.ship.maxammo:
            self.ship.ammo += self.ship.reload
            if self.ship.ammo > self.ship.maxammo:
                self.ship.ammo = self.ship.maxammo
            print(f"El enemigo recargó su munición. Munición actual: {self.ship.ammo}")
        else:
            print("El enemigo tiene la munición llena.")

    def repair(self):
        if self.ship.hull < self.ship.maxhull:
            repaired = random.randint(0, self.ship.repair)
            self.ship.hull += repaired
            if self.ship.hull > self.ship.maxhull:
                self.ship.hull = self.ship.maxhull
            print(f"El enemigo reparó su barco. Integridad del buque: {self.ship.hull}")
        else:
            print("El enemigo no tiene daños que reparar.")

player_name = input("Ingresa tu nombre: ")
player = Player(player_name)
player.choose_ship(ships)
player.show_ship()

enemy = Enemy()
enemy.enemy_select(ships)

player.playing(enemy)
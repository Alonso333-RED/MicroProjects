let pyodide;

const statusEl = document.getElementById("status");
const runBtn = document.getElementById("run-btn");
const output = document.getElementById("output");
const stdin = document.getElementById("stdin");

let manifest = { entry: "main.py", files: ["main.py"] };

// Resuelve la promesa pendiente de input(), si el programa está esperando.
let pendingInputResolve = null;


function write(text) {
    output.textContent += text;
    output.scrollTop = output.scrollHeight;
}

function setStatus(text, kind) {
    statusEl.textContent = text;
    statusEl.className = kind || "";
}


// =========================
// Entrada de teclado (stdin)
// =========================

stdin.addEventListener("keydown", (event) => {

    if (event.key !== "Enter") {
        return;
    }

    if (!pendingInputResolve) {
        return;
    }

    const value = stdin.value;

    write(`${value}\n`);

    stdin.value = "";
    stdin.disabled = true;

    const resolve = pendingInputResolve;
    pendingInputResolve = null;

    resolve(value);
});


// Función expuesta a Python: escribe el prompt de inmediato (sin pasar por
// el stdout de Python, que puede quedar bufferizado mientras input() está
// suspendido) y devuelve una Promise que se resuelve cuando el usuario
// presiona Enter en el campo de stdin.
function getUserInput(promptText) {
    return new Promise((resolve) => {

        if (promptText) {
            write(promptText);
        }

        pendingInputResolve = resolve;
        stdin.disabled = false;
        stdin.focus();
        setStatus("Esperando entrada del usuario...", "waiting");
    });
}


// =========================
// Carga de Pyodide y del programa
// =========================

async function loadManifest() {

    try {

        const response = await fetch("./program/manifest.json");

        if (response.ok) {
            manifest = await response.json();
        }

    } catch (error) {
        // Si no hay manifest.json, se usa el valor por defecto (main.py).
    }
}


async function loadProgramFiles() {

    pyodide.FS.mkdirTree("/program");

    for (const relativePath of manifest.files) {

        const response = await fetch(`./program/${relativePath}`);

        if (!response.ok) {
            throw new Error(`No se pudo cargar program/${relativePath}`);
        }

        const text = await response.text();

        const fullPath = `/program/${relativePath}`;
        const dir = fullPath.substring(0, fullPath.lastIndexOf("/"));

        pyodide.FS.mkdirTree(dir);
        pyodide.FS.writeFile(fullPath, text);
    }

    pyodide.FS.chdir("/program");
}


async function setupPython() {

    pyodide.globals.set("__js_get_input", getUserInput);

    pyodide.runPython(`
import sys, builtins

if "/program" not in sys.path:
    sys.path.insert(0, "/program")


async def __run_program(filename):
    from pyodide.ffi import run_sync

    def __console_input(prompt=""):
        sys.stdout.flush()
        sys.stderr.flush()
        return run_sync(__js_get_input(prompt))

    builtins.input = __console_input

    # El programa se lee y ejecuta tal como está en disco: es un
    # script Python normal, independiente, que no sabe que corre
    # dentro de un navegador.
    with open(filename, encoding="utf-8") as f:
        source = f.read()

    g = {"__name__": "__main__"}
    code = compile(source, filename, "exec")
    exec(code, g)
`);
}


async function init() {

    write("Cargando Python (Pyodide)...\n");

    pyodide = await loadPyodide({
        indexURL: "./pyodide/"
    });

    pyodide.setStdout({ batched: (text) => write(text + "\n") });
    pyodide.setStderr({ batched: (text) => write(text + "\n") });

    await loadManifest();
    await loadProgramFiles();
    await setupPython();

    write("Listo. Presiona 'Ejecutar' para iniciar el programa.\n\n");

    setStatus("Listo", "");
    runBtn.disabled = false;
}


// =========================
// Ejecutar
// =========================

async function runProgram() {

    runBtn.disabled = true;
    stdin.value = "";
    pendingInputResolve = null;
    stdin.disabled = true;

    write("\n----- Ejecutando -----\n\n");
    setStatus("Ejecutando...", "running");

    const runFn = pyodide.globals.get("__run_program");

    try {

        // callPromising habilita JS Promise Integration (stack switching),
        // necesario para que run_sync() bloquee de verdad en cada input().
        await runFn.callPromising(manifest.entry);

        write("\n----- Programa finalizado -----\n");
        setStatus("Finalizado", "");

    } catch (error) {

        const message = error.message ? error.message : String(error);

        write(`\n${message}\n`);

        if (message.toLowerCase().includes("stack switching")) {
            write("\nTu navegador no soporta JS Promise Integration (necesaria para\n");
            write("que input() bloquee de verdad). Prueba con Chrome o Edge actualizados.\n");
        }

        write("----- Programa finalizado con error -----\n");
        setStatus("Error", "error");

    } finally {

        runFn.destroy();
        stdin.disabled = true;
        runBtn.disabled = false;
    }
}


runBtn.addEventListener("click", () => {
    runProgram().catch((error) => {
        write(`\nERROR INESPERADO:\n${error}\n`);
        setStatus("Error", "error");
        runBtn.disabled = false;
    });
});


init().catch((error) => {

    write(`\nERROR AL CARGAR:\n${error}\n`);
    setStatus("Error al cargar", "error");

    if (String(error).toLowerCase().includes("promising") ||
        String(error).toLowerCase().includes("stack switching")) {

        write("\nTu navegador podría no soportar JS Promise Integration.\n");
        write("Prueba con una versión reciente de Chrome o Edge.\n");
    }
});

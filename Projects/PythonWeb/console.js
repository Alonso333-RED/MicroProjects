let pyodide;

const statusEl = document.getElementById("status");
const output = document.getElementById("output");
const command = document.getElementById("command");

const history = [];
let historyIndex = -1;


function write(text) {
    output.textContent += text;
    output.scrollTop = output.scrollHeight;
}

function setStatus(text, kind) {
    statusEl.textContent = text;
    statusEl.className = kind || "";
}


async function startPython() {

    write("Cargando Python...\n");

    pyodide = await loadPyodide({
        indexURL: "./pyodide/"
    });

    // Redirigir stdout de Python hacia nuestra terminal
    pyodide.setStdout({
        batched: (text) => {
            write(text + "\n");
        }
    });

    // Redirigir stderr también
    pyodide.setStderr({
        batched: (text) => {
            write(text + "\n");
        }
    });

    write("Python cargado.\n\n");
    write("Python Web Console\n");
    write("Escribe una expresión o instrucción Python.\n\n");

    setStatus("Listo", "waiting");
    command.focus();
}


command.addEventListener("keydown", async (event) => {

    // =========================
    // HISTORIAL ↑
    // =========================

    if (event.key === "ArrowUp") {

        if (history.length === 0) {
            return;
        }

        if (historyIndex < history.length - 1) {
            historyIndex++;
        }

        command.value =
            history[history.length - 1 - historyIndex];

        event.preventDefault();

        return;
    }


    // =========================
    // HISTORIAL ↓
    // =========================

    if (event.key === "ArrowDown") {

        if (historyIndex > 0) {

            historyIndex--;

            command.value =
                history[history.length - 1 - historyIndex];

        } else {

            historyIndex = -1;
            command.value = "";
        }

        event.preventDefault();

        return;
    }


    // =========================
    // ENTER
    // =========================

    if (event.key !== "Enter") {
        return;
    }


    const code = command.value;

    command.value = "";


    if (code.trim() === "") {
        write(">>>\n");
        return;
    }


    history.push(code);
    historyIndex = -1;


    write(`>>> ${code}\n`);

    setStatus("Ejecutando...", "");

    try {

        const result = await pyodide.runPythonAsync(code);

        if (result !== undefined && result !== null) {
            write(`${result}\n`);
        }

    } catch (error) {

        write(`${error}\n`);
    }


    write("\n");
    setStatus("Listo", "waiting");
});


startPython().catch(error => {

    write(`\nERROR:\n${error}\n`);
    setStatus("Error al cargar", "error");

});

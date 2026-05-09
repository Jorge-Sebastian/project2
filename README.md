# VeriLang - Proyecto 3 PLE

Implementacion en Rascal de VeriLang para el Proyecto 3 de PLE.

El proyecto define la sintaxis concreta, un AST propio, parser, conversion de parse tree a AST, generacion de salida en consola, validacion de tipos/referencias y una integracion basica con TypePal para definiciones/usos desde el plugin.

## Estructura

- `src/main/rascal/Syntax.rsc`: gramatica concreta de VeriLang.
- `src/main/rascal/AST.rsc`: arbol de sintaxis abstracta.
- `src/main/rascal/Parser.rsc`: parser y carga de programas `.vl`.
- `src/main/rascal/ToAST.rsc`: conversion del parse tree al AST propio.
- `src/main/rascal/Generator.rsc`: generador de salida en consola desde el AST.
- `src/main/rascal/TypeChecker.rsc`: validaciones semanticas y de tipos.
- `src/main/rascal/Checker.rsc`: integracion TypePal para definiciones/usos.
- `src/main/rascal/Main.rsc`: punto de entrada principal.
- `src/main/rascal/CheckExamples.rsc`: ejecucion de ejemplos correctos y con errores.
- `instance/`: programas VeriLang de prueba en formato `.vl`.
- `docs/`: informe de entrega en Markdown y Word.

## Ejecucion recomendada en Rascal

En VS Code con la extension de Rascal:

1. Abrir `src/main/rascal/Main.rsc`.
2. Ejecutar la accion `Run in new Rascal terminal` sobre la funcion `runDefault`.
3. Revisar en consola la salida generada para `instance/spec1.vl` y el resultado del chequeo de tipos.

Para ejecutar todos los ejemplos, abrir `src/main/rascal/CheckExamples.rsc` y correr `runExamples`.

Tambien se puede hacer desde una terminal de Rascal. Para ejecutar el ejemplo principal:

```rascal
import Main;
runDefault();
```

Para ejecutar cualquier archivo `.vl` del proyecto:

```rascal
import Main;
runFile(|project://js-otalorab12-project-verilang/instance/spec1.vl|);
```

Para validar todos los ejemplos incluidos:

```rascal
import CheckExamples;
runExamples();
```

## Ejecucion alternativa desde consola del sistema

Desde la raiz del proyecto tambien se puede ejecutar:

```powershell
java -jar "$env:USERPROFILE\.m2\repository\org\rascalmpl\rascal\0.42.1\rascal-0.42.1.jar" Main
```

Para revisar todos los ejemplos desde consola del sistema:

```powershell
java -jar "$env:USERPROFILE\.m2\repository\org\rascalmpl\rascal\0.42.1\rascal-0.42.1.jar" CheckExamples
```

## Ejemplos incluidos

- `instance/spec1.vl`: programa principal valido con modulos, espacios, operadores, variables, estructuras, reglas, expresiones y ecuaciones.
- `instance/spec_typed_values.vl`: programa valido enfocado en valores anotados con `Int`, `Bool`, `Char`, `String` y `Real`.
- `instance/spec_error.vl`: programa intencionalmente incorrecto para demostrar errores de tipos y referencias.

## Plugin

En VS Code con Rascal se puede ejecutar `Plugin.registerVerilang` para registrar el lenguaje `.vl`.

Si se ejecuta el plugin desde consola, se necesita incluir `rascal-lsp` en el classpath. En ese escenario puede aparecer el warning `Could not register language: no connection`, que es esperado porque no hay conexion activa con el editor.

## Entrega

La carpeta `referencias/` contiene material de trabajo local y no hace parte de la entrega final. Tambien se excluye `target/` porque contiene artefactos generados por Maven.

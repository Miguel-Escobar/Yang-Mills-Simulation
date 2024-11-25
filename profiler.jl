# Genera (para vscode) un flamegraph de la simulación de U(1).
include("src//ambient_space//z2_lattice.jl")
import .z2_lattice: initialize_model
using Agents

group = "Z1000"
height = 50
width = 50
β = 1.0

model = initialize_model(width, height, β, group)

@profview step!(model, 100) # Sólo funciona si tienes la extension de Julia instalada en VSCode

"""
Esto te va a mostrar lo que se llama un "Flame Graph" de lo que está tomando tiempo en tu código. 
Las secciones que están abajo de otra es porque están siendo llamadas por lo de arriba. El ancho es proporcional al tiempo que toma cada parte.
Por ejemplo, si de una función salen 3 bloques, uno mucho más grande que los otros 2, puedo asegurarme que ahí es donde debiera optimizar.
Los colores también significan cosas. Eso no se muy bien, pero debe estar documentado en profview. Tiene que ver con si Julia está teniendo que adivinar
el tipo de dato que está trabajando o si no. Esto también es fácil de acelerar pues sólo le dices el tipo de dato y listo. Creo que lo más grave es cuando aparece gris.
Otro dato: Task Done y cosas así parece que tienen que ver con multiprocessing. Eso los hace un poco más difíciles de estudiar. Hay que tener ojo ahí.
""";
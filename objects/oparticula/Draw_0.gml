// Desenha a partícula baseado no efeito
switch (efeito) {
    case "agua":
        draw_set_color(c_aqua);
        draw_circle(x, y, 4, false);
        break;
    case "sucesso":
        draw_set_color(c_lime);
        draw_circle(x, y, 6, false);
        draw_set_color(c_yellow);
        draw_circle(x, y, 3, false);
        break;
    case "erro":
        draw_set_color(c_red);
        draw_circle(x, y, 5, false);
        break;
}

draw_set_color(c_white);






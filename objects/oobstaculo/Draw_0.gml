// Desenha o obstáculo
draw_set_color(cor_obstaculo);
draw_set_alpha(0.8);

// Desenha baseado no tipo
switch (tipo_obstaculo) {
    case "bloco":
        draw_rectangle(x-24, y-24, x+24, y+24, false);
        draw_set_color(c_white);
        draw_rectangle(x-24, y-24, x+24, y+24, true);
        break;
    case "agua":
        draw_circle(x, y, 20, false);
        draw_set_color(c_white);
        draw_circle(x, y, 20, true);
        break;
    case "fogo":
        draw_circle(x, y, 20, false);
        draw_set_color(c_orange);
        draw_circle(x, y, 15, false);
        draw_set_color(c_yellow);
        draw_circle(x, y, 10, false);
        break;
}

draw_set_alpha(1);
draw_set_color(c_white);






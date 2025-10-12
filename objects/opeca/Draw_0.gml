// Animação de hover quando o mouse está sobre a peça
var mouse_over = (mouse_x > x-32 && mouse_x < x+32 && mouse_y > y-32 && mouse_y < y+32);

if (mouse_over) {
    // Efeito de hover - aumenta ligeiramente o tamanho
    var scale_hover = 1.1;
    draw_set_color(c_white);
    draw_set_alpha(0.3);
    draw_circle(x, y, 32 * scale_hover, false);
    draw_set_alpha(1);
}

// Desenha o sprite da peça com animação
if (arrastando) {
    // Efeito de arrastar - aumenta o tamanho e adiciona sombra
    var scale_drag = 1.2;
    draw_set_color(c_black);
    draw_set_alpha(0.3);
    draw_circle(x+3, y+3, 32 * scale_drag, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_self();

// Se tem água, adiciona efeito visual animado
if (tem_agua) {
    // Animação pulsante da água
    var pulse = sin(current_time * 0.01) * 0.2 + 0.8;
    draw_set_alpha(0.4 * pulse);
    draw_set_color(c_aqua);
    draw_circle(x, y, 24 * pulse, false);
    
    // Efeito de brilho
    draw_set_alpha(0.6 * pulse);
    draw_set_color(c_white);
    draw_circle(x, y, 16 * pulse, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}


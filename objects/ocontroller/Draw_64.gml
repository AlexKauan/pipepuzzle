// TELA DE GAME OVER (GUI - sobre tudo)
if (game_over_ativo) {
    // Fundo escurecido por cima de tudo
    draw_set_color(c_black);
    draw_set_alpha(0.85);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);

    // Texto principal (centralizado)
    var centro_x = display_get_gui_width() / 2;
    var centro_y = display_get_gui_height() / 2;

    draw_set_color(c_white);
    draw_set_font(fnt_game);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_text(centro_x, centro_y - 40, "GAME OVER");
    draw_text(centro_x, centro_y + 10, "R = Reiniciar | ESC = Sair");

    draw_set_halign(fa_left); // volta alinhamento padrão
    draw_set_valign(fa_top);
}

// (sem dica em GUI; dica visual é desenhada no Draw principal)


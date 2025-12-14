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

// Hint ativo (entre o grid e o painel inferior)
if (mostrar_hint) {
    var hint_x1 = offset_x - 12;
    var hint_x2 = offset_x + grid_width * cell_size + 12;
    var hint_y1 = offset_y + grid_height * cell_size + 8;
    var hint_y2 = hint_y1 + 52; // altura maior para padding

    draw_set_alpha(0.9);
    draw_set_color(make_color_rgb(16, 28, 44));
    draw_roundrect(hint_x1, hint_y1, hint_x2, hint_y2, false);
    draw_set_color(make_color_rgb(255, 204, 80));
    draw_roundrect(hint_x1 + 2, hint_y1 + 2, hint_x2 - 2, hint_y2 - 2, false);

    draw_set_alpha(1);
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var texto_hint = "💡 " + string(hint_texto_atual);
    var hint_cx = (hint_x1 + hint_x2) * 0.5;
    var hint_cy = (hint_y1 + hint_y2) * 0.5;
    draw_text_ext(hint_cx, hint_cy, texto_hint, 1.6, 4000);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


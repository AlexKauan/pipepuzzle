// Atualiza vida
vida--;
if (vida <= 0) {
    instance_destroy();
}

// Movimento
x += vel_x;
y += vel_y;
vel_y += gravidade;

// Efeitos visuais baseado no tipo
switch (efeito) {
    case "agua":
        // Movimento suave da água
        vel_x *= 0.98;
        vel_y *= 0.98;
        break;
    case "sucesso":
        // Explosão de sucesso
        vel_x *= 0.95;
        vel_y *= 0.95;
        break;
    case "erro":
        // Tremor de erro
        vel_x *= 0.9;
        vel_y *= 0.9;
        break;
}

// Fade out
image_alpha = (vida / vida_max) * alpha_inicial;
image_xscale = (vida / vida_max) * scale_inicial;
image_yscale = image_xscale;






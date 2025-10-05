#define C_KEY GetChar(0)
#define S_CX GR_WIDTH >> 1
#define S_CY GR_HEIGHT >> 1

F64 M_CX, M_CY = 0; // these are math plane coords, the ones above are for the screen
I64 px, py;
F64 scale = 3.0/GR_WIDTH;

U0 ScreenToComplex(I64 x, I64 y, F64 *re, F64 *im)
{
    *re = M_CX + (x - S_CX) * scale;
    *im = M_CY + (y - S_CY) * scale;
}

Bool K_DOWN(I64 KEY_CODE)
{
    return Bt(kbd.down_bitmap, KEY_CODE);
}

/* well, this isn't really related to fractals
   but it might be useful for camera panning! */
U0 HandleMovement()
{
    if(K_DOWN(SC_CURSOR_UP))    py -= 1;
    if(K_DOWN(C_CURSOR_DOWN))  py += 1;
    if(K_DOWN(SC_CURSOR_LEFT))  px -= 1;
    if(K_DOWN(SC_CURSOR_RIGHT)) px += 1;
}

U0 DrawIt(CTask *t, CDC *dc)
{
    dc->color = WHITE;
    GrRect(dc, 0, 0, GR_WIDTH, GR_HEIGHT);

    dc->color = RED;
    GrRect(dc, px-50, py-50, 100, 100);

    dc->color = BLACK;
    GrPlot(dc, px, py);

    HandleMovement;
}

U0 Main()
{
    SettingsPush;
    WinBorder;
    WinMax;
    DocClear;

    px = S_CX;
    py = S_CY;

    Fs->draw_it = &DrawIt;

    "HolyFract started...\n";

    while(TRUE)
    {
        if(C_KEY == CH_ESC) break;
    }

    "HolyFract aborted...\n";

    F64 re, im;

    ScreenToComplex(S_CX, S_CY, &re, &im); "\nCenter: re=%.2f, im=%.2f\n\n", re, im;
    ScreenToComplex(0, 0, &re, &im); "TopLeft: re=%.2f, im=%.2f\n\n", re, im;
    ScreenToComplex(GR_WIDTH, GR_HEIGHT, &re, &im); "BottomRight: re=%.2f, im=%.2f\n\n", re, im;
    ScreenToComplex(512, 384, &re, &im); "Center: re=%.2f, im=%.2f\n\n", re, im;
    ScreenToComplex(1024, 0, &re, &im); "TopRight: re=%.2f, im=%.2f\n\n", re, im;

    SettingsPop;
}

Main;

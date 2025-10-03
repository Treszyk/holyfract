#define cx GR_WIDTH >> 1
#define cy GR_HEIGHT >> 1
I64 px;
I64 py;

/* well, this isn't really related to fractals
   but it might be useful for camera panning! */
U0 HandleMovement()
{
    if(Bt(kbd.down_bitmap, SC_CURSOR_UP))    py -= 1;
    if(Bt(kbd.down_bitmap, SC_CURSOR_DOWN))  py += 1;
    if(Bt(kbd.down_bitmap, SC_CURSOR_LEFT))  px -= 1;
    if(Bt(kbd.down_bitmap, SC_CURSOR_RIGHT)) px += 1;
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
    px = cx;
    py = cy;

    Fs->draw_it = &DrawIt;

    "HolyFract started...\n";

    while(TRUE)
    {
        I64 ch = GetChar(FALSE);
        if(ch == CH_ESC) break;
    }

    "HolyFract aborted...\n";

    SettingsPop;
}
Main;
